#syntax=harbor.leops.local/library/docker/dockerfile:1

ARG NODE_VERSION=22

FROM harbor.leops.local/common/tools/node:${NODE_VERSION}

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/pm2/Dockerfile" \
      org.opencontainers.image.description="pm2  runtime environment."

# install node
RUN set -eux \
    && npm install -g pm2 \
    && groupadd -r nonroot \
    && useradd -r -m -g nonroot nonroot \
    && mkdir -p /app/logs /home/nonroot/.pm2 \
    && chown nonroot:nonroot -R /app /home/nonroot

USER nonroot:nonroot
ENV PM2_HOME=/home/nonroot/.pm2

CMD [ "pm2-runtime", "start", "ecosystem.config.js" ]
