#syntax=harbor.leops.local/library/docker/dockerfile:1

ARG OPENJDK_VERSION=24

FROM harbor.leops.local/common/tools/openjdk:$OPENJDK_VERSION

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/openjdk/Dockerfile" \
      org.opencontainers.image.description="Minimal base runtime for Openjdk applications with non-root user."


ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"

RUN \
    groupadd -r nonroot \
    && useradd -r -g nonroot nonroot \
    && mkdir -p /app/logs \
    && chown nonroot:nonroot -R /app

USER nonroot:nonroot
