#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/tools/openjdk:24

ARG MAVEN_VERSION=3.9.9

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/tools/maven/Dockerfile" \
      org.opencontainers.image.description="Apache Maven ${MAVEN_VERSION} compiler environment."

ENV MAVEN_HOME=/usr/share/maven \
    MAVEN_CONFIG="/root/.m2"

RUN set -eux; \
    curl -fsSLO --compressed https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz; \
    mkdir -p "${MAVEN_HOME}/ref/repository" "$MAVEN_CONFIG"; \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C ${MAVEN_HOME} --strip-components=1; \
    ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn; \
    mvn --version; \
    rm -fv apache-maven-*.tar.gz;

COPY settings.xml ${MAVEN_CONFIG}/
