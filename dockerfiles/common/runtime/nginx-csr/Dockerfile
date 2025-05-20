#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/os/debian:bullseye

ARG NGINX_VERSION=1.26.3

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/tools/node/Dockerfile" \
      org.opencontainers.image.description="nginx [engine x] is an HTTP and reverse proxy server"

ENV NGINX_VERSION=$NGINX_VERSION

RUN echo 'deb [trusted=yes] https://nginx.org/packages/debian/ bullseye nginx' >> /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y nginx=${NGINX_VERSION}-1~bullseye \
    && apt-get clean \
    && chown www-data.www-data -R /var/cache/nginx \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
