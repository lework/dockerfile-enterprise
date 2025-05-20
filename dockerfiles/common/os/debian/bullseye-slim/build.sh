#!/bin/bash

set -e

# 配置
REGISTRY="harbor.leops.local"
IMAGE_BASE_NAME="common/os/debian"
VERSION="bullseye-20250407-slim"


# 声明镜像地址数组
declare -a IMAGE_PATHS
IMAGE_PATHS+=(
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION}"           # 完整版本
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%%-*}"       # 主版本
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%%-*}-slim"  # 主版本
)


# 构建镜像
build_image() {

    echo "Building and pushing image:"
    for img in "${IMAGE_PATHS[@]}"; do echo -n " $img"; done

    docker buildx build --platform linux/amd64,linux/arm64 \
      $(for img in "${IMAGE_PATHS[@]}"; do echo "-t $img "; done) \
      --build-arg "OS_VERSION=${VERSION}" \
      --label "OS_VERSION=${VERSION}" \
      --label "org.opencontainers.image.created=$(date --rfc-3339=seconds)" \
      --provenance=false \
      --pull \
      --push \
      .

    echo "Build complete."
}


# 参数处理
case "$1" in
    "list-tags")
        # 输出镜像标签列表
        printf '%s\n' "${IMAGE_PATHS[@]}"
        ;;
    *)
    build_image
    ;;
esac
