#!/bin/bash

#!/bin/bash

set -e

# 配置
REGISTRY="harbor.leops.local"
IMAGE_BASE_NAME="common/tools/maven"
VERSION="3.9.9"


# 声明镜像地址数组
declare -a IMAGE_PATHS
IMAGE_PATHS+=(
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION}"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%.*}"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%%.*}"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION}-debian11"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%.*}-debian11"
    "${REGISTRY}/${IMAGE_BASE_NAME}:${VERSION%%.*}-debian11"
)


build_image() {

    echo "Building and pushing image:"
    for img in "${IMAGE_PATHS[@]}"; do echo -e " $img"; done

    # 构建镜像
    docker buildx build \
      $(for img in "${IMAGE_PATHS[@]}"; do echo -n "-t $img "; done) \
      --label "org.opencontainers.image.created=$(date --rfc-3339=seconds)" \
      --build-arg "MAVEN_VERSION=${VERSION}" \
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
