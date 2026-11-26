#!/bin/bash

set -e

cd -- "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

set +o noglob

usage=$'Please set hostname and other necessary attributes in harbor.yml first. DO NOT use localhost or 127.0.0.1 for hostname, because Harbor needs to be accessed by external clients.
Please set --with-trivy if needs enable Trivy in Harbor.
Please do NOT set --with-chartmuseum, as chartmusuem has been deprecated and removed.
Please do NOT set --with-notary, as notary has been deprecated and removed.'
item=0

with_trivy=false

# flag to using docker compose v1 or v2, default would using v1 docker-compose
DOCKER_COMPOSE=docker-compose

while [ $# -gt 0 ]; do
        case $1 in
            --help)
            note "$usage"
            exit 0;;
            --with-trivy)
            with_trivy=true;;
            *)
            note "$usage"
            exit 1;;
        esac
        shift || true
done

if [ ! -f harbor.yml ]; then
    error "请复制 harbor.yml.tmpl 为 harbor.yml 并配置本机的 Harbor 地址和密码" >&2
    exit 1
fi

if grep -Eq '^[[:blank:]]*(harbor_admin_password|password):[[:blank:]]+CHANGE_ME[[:blank:]]*$' harbor.yml; then
    error "请替换 harbor.yml 中的密码占位符 CHANGE_ME" >&2
    exit 1
fi

h2 "[Step $item]: checking if docker is installed ..."; let item+=1
check_docker

h2 "[Step $item]: checking docker-compose is installed ..."; let item+=1
check_dockercompose

# 配置生成器会重建组件配置，已有实例先走维护流程
if [ -f docker-compose.yml ]; then
    existing_containers=$($DOCKER_COMPOSE ps -aq)
else
    existing_containers=$(docker ps -aq --filter 'name=^/harbor-core$')
fi
if [ -n "$existing_containers" ]; then
    error "检测到已有 Harbor 实例。请备份数据并按第 32 章的配置变更步骤维护。" >&2
    exit 1
fi

if [ -f harbor*.tar.gz ]
then
    h2 "[Step $item]: loading Harbor images ..."; let item+=1
    docker load -i ./harbor*.tar.gz
fi
echo ""

h2 "[Step $item]: preparing environment ...";  let item+=1
if [ -n "$host" ]
then
    sed "s/^hostname: .*/hostname: $host/g" -i ./harbor.yml
fi

h2 "[Step $item]: preparing harbor configs ...";  let item+=1
prepare_args=()
if "$with_trivy"
then
    prepare_args+=(--with-trivy)
fi

bash ./prepare "${prepare_args[@]}"
echo ""

h2 "[Step $item]: starting Harbor ..."
$DOCKER_COMPOSE up -d

success $"----Harbor has been installed and started successfully.----"
