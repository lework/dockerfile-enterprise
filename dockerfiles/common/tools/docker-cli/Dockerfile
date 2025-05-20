#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/os/debian:bullseye

ARG DOCKER_VERSION=28.1.1

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/dind/Dockerfile" \
      org.opencontainers.image.description="Docker CLI tools"

ENV DOCKER_BUILDKIT=1

# install dependencies
RUN set -eux; \
    echo "deb [trusted=yes] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker-ce.list; \
    apt-get update; \
    apt-get install -y -qq --no-install-recommends git docker-buildx-plugin docker-ce-cli=5:${DOCKER_VERSION}-1~debian.11~bullseye; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log;
