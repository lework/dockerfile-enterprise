#syntax=harbor.leops.local/library/docker/dockerfile:1
#                                                                                       
# ---- 编译环境 ----

FROM harbor.leops.local/common/tools/node:22 AS builder

ARG APP_ENV=test \
    APP=undefine \
    GIT_BRANCH= \
    GIT_COMMIT_ID=

ENV APP_ENV=$APP_ENV \
    APP=$APP \
    GIT_BRANCH=$GIT_BRANCH \
    GIT_COMMIT_ID=$GIT_COMMIT_ID

WORKDIR /app_build

# Nuxt 的 postinstall 需要项目配置
COPY . .
RUN --mount=type=cache,id=${APP}-npm,target=/root/.npm \
    npm ci && npm run "build:${APP_ENV}"


#
# ---- 运行环境 ----

FROM harbor.leops.local/common/runtime/pm2:node-22 AS running

ARG APP_ENV=test \
    APP=undefine \
    GIT_BRANCH= \
    GIT_COMMIT_ID=

ENV APP_ENV=$APP_ENV \
    APP=$APP \
    GIT_BRANCH=$GIT_BRANCH \
    GIT_COMMIT_ID=$GIT_COMMIT_ID

WORKDIR /app

COPY --from=builder --chown=nonroot:nonroot /app_build/.output/ /app/
COPY --from=builder /app_build/ecosystem.config.js /app/ecosystem.config.cjs

CMD ["bash", "-c", "exec pm2-runtime start ecosystem.config.cjs --json --env \"${APP_ENV}\""]
