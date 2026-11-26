#!/bin/bash

set -o pipefail

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

if (( BASH_VERSINFO[0] < 4 )); then
    fail "请使用 Bash 4 或更高版本运行 image_manager.sh。"
fi

expand_args() {
    local expression=$1
    shift
    local binding token name resolved=""
    local variable='\$\{([A-Za-z_][A-Za-z_0-9]*)\}|\$([A-Za-z_][A-Za-z_0-9]*)'
    local -A values=()

    for binding; do
        values[${binding%%=*}]=${binding#*=}
    done
    while [[ $expression =~ $variable ]]; do
        token=${BASH_REMATCH[0]}
        name=${BASH_REMATCH[1]:-${BASH_REMATCH[2]}}
        resolved+="${expression%%"$token"*}${values[$name]-$token}"
        expression=${expression#*"$token"}
    done
    printf '%s\n' "$resolved$expression"
}

read_build_args() {
    local script=$1 line argument value
    local assignment='^[[:space:]]*([A-Za-z_][A-Za-z_0-9]*)=("([^"]*)"|([^[:space:]#]+))[[:space:]]*(#.*)?$'
    local build_arg='^[[:space:]]*--build-arg([[:space:]]+|=)("([^"]*)"|([^[:space:]]+))'
    local -a variables=()

    while IFS= read -r line || [[ -n $line ]]; do
        if [[ $line =~ $assignment ]]; then
            variables+=("${BASH_REMATCH[1]}=${BASH_REMATCH[3]}${BASH_REMATCH[4]}")
        elif [[ $line =~ $build_arg ]]; then
            argument=${BASH_REMATCH[3]}${BASH_REMATCH[4]}
            if [[ $argument == *=* ]]; then
                value=$(expand_args "${argument#*=}" "${variables[@]}") || return
                printf '%s=%s\n' "${argument%%=*}" "$value"
            fi
        fi
    done < "$script"
}

parse_froms() {
    local file=$1 build_args=$2 line instruction="" arg name value image flag alias
    local i before_first_from=1
    local arg_name='^[A-Za-z_][A-Za-z_0-9]*$'
    local -a words args=()
    local -A overrides=() stages=()

    while IFS='=' read -r name value; do
        if [[ $name =~ $arg_name ]]; then
            overrides[$name]=$value
        fi
    done <<< "$build_args"

    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        [[ $line =~ ^[[:space:]]*(#|$) ]] && continue
        if [[ $line == *'\' ]]; then
            instruction+=${line%\\}
            continue
        fi
        read -r -a words <<< "$instruction$line"
        instruction=""

        case "${words[0]^^}" in
            ARG)
                (( before_first_from )) || continue
                for arg in "${words[@]:1}"; do
                    name=${arg%%=*}
                    [[ $name =~ $arg_name ]] || continue
                    if [[ ${overrides[$name]+set} ]]; then
                        args+=("$name=${overrides[$name]}")
                    elif [[ $arg == *=* ]]; then
                        value=${arg#*=}
                        value=${value#\"}
                        value=${value%\"}
                        value=${value#\'}
                        value=${value%\'}
                        value=$(expand_args "$value" "${args[@]}") || return
                        args+=("$name=$value")
                    fi
                done
                ;;
            FROM)
                before_first_from=0
                i=1
                while [[ ${words[i]-} == --* ]]; do
                    ((i += 1))
                done
                image=$(expand_args "${words[i]-}" "${args[@]}") || return
                if [[ -z "$image" ]]; then
                    printf '%s 中的 FROM 缺少镜像名。\n' "$file" >&2
                    return 1
                fi
                if [[ ! ${stages[${image,,}]+set} ]]; then
                    printf '%s\n' "$image"
                fi
                flag=${words[i+1]-}
                alias=${words[i+2]-}
                if [[ ${flag^^} == AS && -n $alias ]]; then
                    stages[${alias,,}]=1
                fi
                ;;
        esac
    done < "$file"
}

canonical_ref() {
    local ref=$1
    if [[ $ref == *@* || ${ref##*/} == *:* ]]; then
        printf '%s\n' "$ref"
    else
        printf '%s:latest\n' "$ref"
    fi
}

declare -a aliases=()
declare -A froms=() tags=() parents=() children=()

load_images() {
    local files file directory alias build_script overrides refs ref owner
    local -A owners=()
    files=$(find "$root" -type f \( -name Dockerfile -o -name 'Dockerfile-*' -o -name 'Dockerfile.*' \) | LC_ALL=C sort) ||
        fail "扫描 Dockerfile 失败。目录 $root"
    [[ -n "$files" ]] || fail "目录 $root 中没有 Dockerfile。"

    while IFS= read -r file; do
        directory=${file%/*}
        alias=${directory#"$root"}
        alias=${alias#/}
        alias=${alias:-.}
        build_script="$directory/build.sh"

        if [[ ! ${tags[$alias]+set} ]]; then
            aliases+=("$alias")
            tags[$alias]=""
            if [[ -f "$build_script" ]]; then
                tags[$alias]=$(cd -- "$directory" && bash ./build.sh list-tags | LC_ALL=C sort -u) ||
                    fail "读取 $build_script 的 list-tags 失败。"
                [[ -n ${tags[$alias]} ]] || fail "$build_script list-tags 未返回镜像标签。"
            fi
        fi

        overrides=""
        if [[ $file == "$directory/Dockerfile" && -f "$build_script" ]]; then
            overrides=$(read_build_args "$build_script") || fail "读取 $build_script 的构建参数失败。"
        fi
        refs=$(parse_froms "$file" "$overrides") || fail "解析 $file 失败。"
        if [[ -n $refs ]]; then
            froms[$alias]+="$refs"$'\n'
        fi
    done <<< "$files"

    for alias in "${aliases[@]}"; do
        while IFS= read -r ref; do
            [[ -n $ref ]] || continue
            [[ $ref != *[[:space:]]* && $ref != *'$'* ]] ||
                fail "$alias 的 list-tags 返回无效镜像引用 $ref。"
            ref=$(canonical_ref "$ref")
            owner=${owners[$ref]-}
            [[ -z $owner || $owner == "$alias" ]] ||
                fail "镜像 $ref 由 $owner 和 $alias 同时声明。"
            owners[$ref]=$alias
        done <<< "${tags[$alias]}"
    done

    for alias in "${aliases[@]}"; do
        refs=$(printf '%s' "${froms[$alias]-}" | LC_ALL=C sort -u) ||
            fail "整理 $alias 的 FROM 列表失败。"
        froms[$alias]=$refs
        while IFS= read -r ref; do
            [[ -n $ref && $ref != scratch ]] || continue
            ref=$(canonical_ref "$ref")
            owner=${owners[$ref]-}
            [[ -n $owner ]] || continue
            if [[ $'\n'${parents[$alias]-} != *$'\n'"$owner"$'\n'* ]]; then
                parents[$alias]+="$owner"$'\n'
                children[$owner]+="$alias"$'\n'
            fi
        done <<< "$refs"
    done
}

list_images() {
    local alias ref width=4
    for alias in "${aliases[@]}"; do
        (( ${#alias} <= width )) || width=${#alias}
    done
    printf '所有镜像信息：\n\n%-*s  %s\n' "$width" '别名' '镜像地址'
    for alias in "${aliases[@]}"; do
        while IFS= read -r ref; do
            [[ -n $ref ]] || continue
            printf '%-*s  %s\n' "$width" "$alias" "$ref"
            alias=""
        done <<< "${tags[$alias]}"
    done
}

show_dependencies() {
    local alias=$1
    printf '镜像 %s 的依赖关系：\n\n依赖的镜像：\n%s\n\n编译后的标签列表：\n%s\n\n被以下镜像依赖：\n%s' \
        "$alias" "${froms[$alias]}" "${tags[$alias]}" "${children[$alias]-}"
}

declare -A shown=() tree_path=()

print_tree() {
    local alias=$1 indent=$2 child
    printf '%s%s' "$indent" "$alias"
    if [[ ${tree_path[$alias]-} ]]; then
        printf ' (循环依赖)\n'
        return
    fi
    printf '\n'
    shown[$alias]=1
    tree_path[$alias]=1
    while IFS= read -r child; do
        [[ -n $child ]] || continue
        print_tree "$child" "$indent  "
    done <<< "${children[$alias]-}"
    tree_path[$alias]=""
}

show_tree() {
    local alias=$1
    if [[ -n $alias ]]; then
        print_tree "$alias" ''
        return
    fi

    for alias in "${aliases[@]}"; do
        [[ ${parents[$alias]-} ]] || print_tree "$alias" ''
    done
    for alias in "${aliases[@]}"; do
        [[ ${shown[$alias]-} ]] || print_tree "$alias" ''
    done
}

build_dependents() {
    local source=$1 alias child parent status i
    local -a affected=("$source") order=()
    local -A pending=(["$source"]=1)
    [[ -n ${tags[$source]} ]] ||
        fail "$source 没有 build.sh。请在应用代码仓库构建该模板对应的镜像。"

    for ((i = 0; i < ${#affected[@]}; i++)); do
        alias=${affected[i]}
        while IFS= read -r child; do
            [[ -n $child && ! ${pending[$child]+set} ]] || continue
            affected+=("$child")
            pending[$child]=1
        done <<< "${children[$alias]-}"
    done

    # 先排完顺序和检查循环，再执行会推送镜像的脚本。
    local remaining=${#affected[@]} before
    while (( remaining )); do
        before=$remaining
        for alias in "${affected[@]}"; do
            [[ ${pending[$alias]} ]] || continue
            while IFS= read -r parent; do
                if [[ -n $parent && ${pending[$parent]-} ]]; then
                    continue 2
                fi
            done <<< "${parents[$alias]-}"
            pending[$alias]=""
            order+=("$alias")
            remaining=$((remaining - 1))
        done
        (( remaining < before )) || fail "$source 的依赖图存在循环，无法安排构建。"
    done

    if (( ${#order[@]} == 1 )); then
        printf '没有找到依赖 %s 的镜像。\n' "$source"
    fi
    for alias in "${order[@]}"; do
        [[ $alias != "$source" ]] || continue
        if [[ -z ${tags[$alias]} ]]; then
            printf '跳过应用模板 %s。请在应用代码仓库构建。\n' "$alias"
            continue
        fi
        printf '构建 %s\n' "$alias"
        (cd -- "$root/$alias" && bash ./build.sh) || {
            status=$?
            printf '构建 %s 失败，退出码 %s。\n' "$alias" "$status" >&2
            return "$status"
        }
    done
}

usage() {
    printf '用法：%s list | deps <镜像别名> | tree [镜像别名] | build <镜像别名>\n' "$0" >&2
    exit 1
}

command=${1-}
alias=${2-}
case "$command" in
    list) (( $# == 1 )) || usage ;;
    tree) (( $# <= 2 )) || usage ;;
    deps|build) (( $# == 2 )) && [[ -n $alias ]] || usage ;;
    *) usage ;;
esac

root=$(cd -- "${DOCKERFILE_DIR:-$(dirname -- "${BASH_SOURCE[0]}")}" && pwd -P) ||
    fail "无法访问 Dockerfile 目录。请核对 DOCKERFILE_DIR。"
load_images
if [[ -n $alias && ! ${tags[$alias]+set} ]]; then
    fail "找不到镜像别名 $alias。"
fi

case "$command" in
    list) list_images ;;
    deps) show_dependencies "$alias" ;;
    tree) show_tree "$alias" ;;
    build) build_dependents "$alias" ;;
esac
