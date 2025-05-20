#syntax=harbor.leops.local/library/docker/dockerfile:1

ARG PYTHON_VERSION=3.11

FROM harbor.leops.local/common/tools/python:${PYTHON_VERSION}

ARG PYTHON_VERSION=3.11

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/python/Dockerfile" \
      org.opencontainers.image.description="Minimal base runtime for python applications with non-root user."

RUN \
    groupadd -r nonroot \
    && useradd -r -m -g nonroot nonroot \
    && mkdir -p /app/logs \
    && chown nonroot:nonroot -R /app

USER nonroot:nonroot
