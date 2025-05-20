#!/bin/bash

set -e

APP_ENV="$1"
APP="$2"

REGISTRY="harbor.leops.local"
APP_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
APP_GIT_COMMITID=$(git rev-parse --short HEAD)

APP_IMAGE="${REGISTRY}/${APP_ENV}/${APP}"
APP_IMAGE_TAG="${APP_GIT_BRANCH}-${APP_GIT_COMMITID}-$(date +%Y%m%d%H%M)"

docker buildx build \
-t "${APP_IMAGE}:${APP_IMAGE_TAG}" \
--add-host goproxy.leops.local=192.168.77.140 \
--add-host nexus.leops.local=192.168.77.140 \
--add-host verdaccio.leops.local=192.168.77.140 \
--build-arg APP=${APP} \
--build-arg APP_ENV=${APP_ENV} \
--build-arg GIT_BRANCH=${APP_GIT_BRANCH} \
--build-arg GIT_COMMIT_ID=${APP_GIT_COMMITID} \
--progress plain \
--push .

if [[ "$APP_ENV" == "prd" && ${APP_GIT_BRANCH} == "master" ]]; then
  docker tag "${APP_IMAGE}:${APP_IMAGE_TAG}" "${APP_IMAGE}:latest"
  docker push "${APP_IMAGE}:latest"
fi
