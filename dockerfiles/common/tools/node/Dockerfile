FROM harbor.leops.local/common/os/debian:bullseye

ARG NODE_VERSION=22.15.0 \
    YARN_VERSION=1.22.22

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/tools/node/Dockerfile" \
      org.opencontainers.image.description="node ${NODE_VERSION} compiler environment."

ENV NODE_VERSION=$NODE_VERSION \
    YARN_VERSION=$YARN_VERSION \
    NPM_REGISTRY="http://verdaccio.leops.local/" \
    YARN_REGISTRY="http://verdaccio.leops.local/"

# install dependencies
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends git python3 python3-pip gcc g++ make \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# install node
RUN set -eux \
    && curl -fsSLO --compressed "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -zxf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    # smoke test
    && node --version \
    && npm --version \
    # set registry
    && npm config set registry $NPM_REGISTRY \
    && echo "disturl=${NPM_REGISTRY}/-/binary/node/" >> /root/.npmrc \
    && echo "sass_binary_site=${NPM_REGISTRY}/-/binary/node-sass" >> /root/.npmrc \
    && echo "canvas_binary_host_mirror=${NPM_REGISTRY}/-/binary/canvas" >> /root/.npmrc \
    && echo "python_mirror=${NPM_REGISTRY}/-/binary/python/" >> /root/.npmrc \
    && npm config list

# install yarn
RUN set -eux \
    && curl -fsSLO -k --compressed "https://github.com/yarnpkg/yarn/releases/download/v$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && mkdir -p /opt \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm -fv yarn-v$YARN_VERSION.tar.gz \
    # smoke test
    && yarn --version \
    # set registry
    && yarn config set registry $YARN_REGISTRY \
    && yarn config list
