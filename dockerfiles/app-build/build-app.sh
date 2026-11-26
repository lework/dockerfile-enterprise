#!/bin/bash

set -e

if [[ $# -ne 2 || -z "$1" || -z "$2" ]]; then
  printf '用法：bash %s <环境> <应用>\n' "$0" >&2
  exit 2
fi

APP_ENV="$1"
APP="$2"

REGISTRY="harbor.leops.local"
APP_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
APP_GIT_COMMITID=$(git rev-parse --short HEAD)

APP_IMAGE="${REGISTRY}/${APP_ENV}/${APP}"
BRANCH_TAG=$(printf '%s' "$APP_GIT_BRANCH" | LC_ALL=C tr -c 'A-Za-z0-9_.-' '-')
if [[ "$BRANCH_TAG" != [a-zA-Z0-9_]* ]]; then
  BRANCH_TAG="_${BRANCH_TAG}"
fi
TAG_SUFFIX="-${APP_GIT_COMMITID}-$(date +%Y%m%d%H%M)"
MAX_BRANCH_TAG_LENGTH=$((128 - ${#TAG_SUFFIX}))
if [[ "$BRANCH_TAG" != "$APP_GIT_BRANCH" || ${#BRANCH_TAG} -gt $MAX_BRANCH_TAG_LENGTH ]]; then
  # 保留原分支摘要，避免分支替换或截断后使用同一标签
  BRANCH_ID=$(printf '%s' "$APP_GIT_BRANCH" | git hash-object --stdin)
  BRANCH_TAG="${BRANCH_TAG:0:$((MAX_BRANCH_TAG_LENGTH - 9))}-${BRANCH_ID:0:8}"
fi
APP_IMAGE_TAG="${BRANCH_TAG}${TAG_SUFFIX}"
IMAGE_TAGS=(-t "${APP_IMAGE}:${APP_IMAGE_TAG}")
if [[ "$APP_ENV" == "prd" && "$APP_GIT_BRANCH" == "master" ]]; then
  IMAGE_TAGS+=(-t "${APP_IMAGE}:latest")
fi

docker buildx build \
  "${IMAGE_TAGS[@]}" \
  --add-host goproxy.leops.local=192.168.77.140 \
  --add-host nexus.leops.local=192.168.77.140 \
  --add-host verdaccio.leops.local=192.168.77.140 \
  --build-arg "APP=${APP}" \
  --build-arg "APP_ENV=${APP_ENV}" \
  --build-arg "GIT_BRANCH=${APP_GIT_BRANCH}" \
  --build-arg "GIT_COMMIT_ID=${APP_GIT_COMMITID}" \
  --progress plain \
  --push .
