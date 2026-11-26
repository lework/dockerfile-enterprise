#syntax=harbor.leops.local/library/docker/dockerfile:1

ARG PHP_VERSION=8.4

FROM harbor.leops.local/common/tools/php:${PHP_VERSION}

ARG PHP_VERSION=8.4

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/yii/Dockerfile" \
      org.opencontainers.image.description="Yii runtime environment."

# install dependencies
RUN set -eux; \
    echo 'deb [trusted=yes] https://nginx.org/packages/debian/ bullseye nginx' > /etc/apt/sources.list.d/nginx.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            nginx \
            supervisor; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log;

# Install CacheTool
RUN curl -s -L https://github.com/gordalina/cachetool/releases/download/7.1.0/cachetool.phar -o /opt/cachetool.phar \
    && chmod +x /opt/cachetool.phar \
    && echo 'cachetool(){ php /opt/cachetool.phar --fcgi=127.0.0.1:9000 --tmp-dir=/tmp $@;}' >> /etc/bash.bashrc

COPY --from=hipages/php-fpm_exporter:2.2.0 /php-fpm_exporter /usr/local/bin/
COPY etc /etc
COPY --chmod=0755 scripts/entrypoint.sh /scripts/entrypoint.sh

WORKDIR /app

CMD ["/scripts/entrypoint.sh"]
