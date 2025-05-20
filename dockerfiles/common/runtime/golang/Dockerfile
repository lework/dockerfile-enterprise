#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/os/debian:bullseye

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/go/Dockerfile" \
      org.opencontainers.image.description="Minimal base runtime for Go applications with non-root user."


RUN \
    groupadd -r nonroot \
    && useradd -r -g nonroot nonroot \
    && mkdir -p /app/logs \
    && chown nonroot:nonroot -R /app

USER nonroot:nonroot
