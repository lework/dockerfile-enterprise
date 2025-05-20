#!/bin/bash

set -e

# 配置
REGISTRY="harbor.leops.local"
IMAGE_BASE_NAME="common/tools/openjdk"
VERSION="24-ea+36"
JAVA_FILE_URL="https://download.java.net/java/GA/jdk24/1f9ff9062db4449d8ca828c504ffae90/36/GPL/openjdk-24"


# 声明镜像地址数组
declare -a IMAGE_PATHS
IMAGE_PATHS+=(
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION/\+/_}"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%%-*}"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION/\+/_}-debian11"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%%-*}-debian11"
)


build_image() {

    echo "Building and pushing image:"
    for img in "${IMAGE_PATHS[@]}"; do echo -n " $img"; done

    # 构建镜像
    docker buildx build \
      $(for img in "${IMAGE_PATHS[@]}"; do echo -n "-t $img "; done) \
      --label "org.opencontainers.image.created=$(date --rfc-3339=seconds)" \
      --build-arg "JAVA_VERSION=${VERSION}" \
      --build-arg "JAVA_FILE_URL=${JAVA_FILE_URL}" \
      --add-host nexus.leops.local=192.168.77.140 \
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
