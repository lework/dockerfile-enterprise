#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/os/debian:bullseye

ARG GOLANG_VERSION=1.24.2

LABEL GOLANG_VERSION="${GOLANG_VERSION}" \
      org.opencontainers.image.maintainer="ops@leops.local" \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/tools/golang/Dockerfile" \
      org.opencontainers.image.description="golang ${GOLANG_VERSION} compiler environment."

ENV GOLANG_VERSION=$GOLANG_VERSION \
    GOPATH=/go \
    CGO_ENABLED=1 \
    GO111MODULE=on \
    GOPROXY=http://goproxy.leops.local,direct

ENV PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# install cgo-related dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            git \
            g++ \
            gcc \
            make \
            cmake \
            pkg-config \
            binutils \
            libc6-dev \
            libstdc++6 \
            libssl-dev \
            libsasl2-dev \
            libzstd-dev \
            libcurl4-openssl-dev \
            ; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log;


# install golang
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
    url=; \
    case "$arch" in \
        'amd64') \
            url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
            ;; \
        'armel') \
            export GOARCH='arm' GOARM='5' GOOS='linux'; \
            ;; \
        'armhf') \
            url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-armv6l.tar.gz"; \
            ;; \
        'arm64') \
            url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-arm64.tar.gz"; \
            ;; \
        'i386') \
            url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-386.tar.gz"; \
            ;; \
        'mips64el') \
            export GOARCH='mips64le' GOOS='linux'; \
            ;; \
        'ppc64el') \
            url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-ppc64le.tar.gz"; \
            ;; \
        's390x') \
            url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-s390x.tar.gz"; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
    esac; \
    build=; \
    if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
        build=1; \
        url="https://dl.google.com/go/go${GOLANG_VERSION}.src.tar.gz"; \
        echo >&2; \
        echo >&2 "warning: current architecture ($arch) does not have a compatible Go binary release; will be building from source"; \
        echo >&2; \
    fi; \
    \
    wget -O go.tgz "$url" --progress=dot:giga; \
    \
# https://github.com/golang/go/issues/14739#issuecomment-324767697
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz; \
    \
    if [ -n "$build" ]; then \
        savedAptMark="$(apt-mark showmanual)"; \
        apt-get update; \
        apt-get install -y --no-install-recommends golang-go; \
        \
        ( \
            cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
            export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
            ./make.bash; \
        ); \
        \
        apt-mark auto '.*' > /dev/null; \
        apt-mark manual $savedAptMark > /dev/null; \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        apt-get clean; \
        rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
        truncate -s 0 /var/log/*log; \
        \
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
        rm -rf \
            /usr/local/go/pkg/*/cmd \
            /usr/local/go/pkg/bootstrap \
            /usr/local/go/pkg/obj \
            /usr/local/go/pkg/tool/*/api \
            /usr/local/go/pkg/tool/*/go_bootstrap \
            /usr/local/go/src/cmd/dist/dist \
        ; \
    fi; \
    \
    go version


# install dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            libprotobuf-dev; \
    PROTOC_VERSION="30.2"; \
    case "$(dpkg --print-architecture)" in \
        amd64) protoc_arch=x86_64 ;; \
        arm64) protoc_arch=aarch_64 ;; \
        *) echo >&2 "当前架构不在本例支持范围内"; exit 1 ;; \
    esac; \
    PROTOC_ZIP="protoc-${PROTOC_VERSION}-linux-${protoc_arch}.zip"; \
    curl -fsSLO "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_ZIP}"; \
    unzip -o $PROTOC_ZIP -d /usr/local bin/protoc; \
    unzip -o $PROTOC_ZIP -d /usr/local 'include/*'; \
    go install honnef.co/go/tools/cmd/staticcheck@latest; \
    go install github.com/go-delve/delve/cmd/dlv@latest; \
    go install gotest.tools/gotestsum@latest; \
    go install github.com/boumenot/gocover-cobertura@latest; \
    go install github.com/elliots/protoc-gen-twirp_swagger@latest; \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest; \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest; \
    go clean -cache; \
    go clean -modcache; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log; \
    rm -rf $GOPATH/pkg/* $PROTOC_ZIP;


WORKDIR $GOPATH
