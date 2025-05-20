#!/bin/bash

set -e

# 配置
REGISTRY="harbor.leops.local"
IMAGE_BASE_NAME="common/runtime/pm2"
VERSION="22"


# 声明镜像地址数组
declare -a IMAGE_PATHS
IMAGE_PATHS+=(
    "${REGISTRY}/${IMAGE_BASE_NAME}:node-${VERSION}"
    "${REGISTRY}/${IMAGE_BASE_NAME}:node-${VERSION%.*}"
)


build_image() {

    echo "Building and pushing image:"
    for img in "${IMAGE_PATHS[@]}"; do echo -e " $img"; done

    # 构建镜像
    docker buildx build \
      $(for img in "${IMAGE_PATHS[@]}"; do echo -n "-t $img "; done) \
      --label "org.opencontainers.image.created=$(date --rfc-3339=seconds)" \
      --add-host verdaccio.leops.local=192.168.77.140 \
      --build-arg "NODE_VERSION=${VERSION}" \
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
