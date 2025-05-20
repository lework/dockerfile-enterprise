#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/os/debian:bullseye

ARG PHP_VERSION=8.4

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/tools/php/Dockerfile" \
      org.opencontainers.image.description="php ${PHP_VERSION} compiler environment."

ENV PHP_VERSION=$PHP_VERSION
	  
# install dependencies
RUN set -eux; \
    echo "deb [trusted=yes] https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list; \
    echo "deb [trusted=yes] https://packages.microsoft.com/debian/11/prod bullseye main" > /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            zip \
            mcrypt \
            libmemcached-dev \
            libreadline-dev \
            libmcrypt-dev \
            libreadline-dev \
            php${PHP_VERSION}-fpm \
            php${PHP_VERSION}-cli \
            php${PHP_VERSION}-curl \
            php${PHP_VERSION}-intl \
            php${PHP_VERSION}-mbstring \
            php${PHP_VERSION}-xsl \
            php${PHP_VERSION}-dev \
            php${PHP_VERSION}-zip \
            php${PHP_VERSION}-mcrypt \
            php${PHP_VERSION}-bcmath \
            php${PHP_VERSION}-bz2 \
            php${PHP_VERSION}-gd \
            php${PHP_VERSION}-igbinary \
            php${PHP_VERSION}-imagick \
            php${PHP_VERSION}-imap \
            php${PHP_VERSION}-ldap \
            php${PHP_VERSION}-memcache \
            php${PHP_VERSION}-mongo \
            php${PHP_VERSION}-mysql \
            php${PHP_VERSION}-redis \
            php${PHP_VERSION}-sqlite3 \
            php${PHP_VERSION}-pgsql  \
            php${PHP_VERSION}-xml \
            php${PHP_VERSION}-xmlrpc \
            php${PHP_VERSION}-readline \
            php${PHP_VERSION}-gmp \
            php${PHP_VERSION}-soap \
            php${PHP_VERSION}-ssh2 \
            php${PHP_VERSION}-xdebug \
            php${PHP_VERSION}-xhprof \
            php${PHP_VERSION}-swoole \
            ghostscript \
            php-pear; \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev libgssapi-krb5-2; \
    sed -i 's#rights="none" pattern="PDF"#rights="read|write" pattern="PDF"#g' /etc/ImageMagick-*/policy.xml; \
    mkdir -p /run/php /var/lib/php/wsdlcache /var/lib/php/session; \
    chown -R www-data /run/php /var/lib/php/wsdlcache /var/lib/php/session; \
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php; \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    composer --version; \
    composer config -g repo.packagist composer http://nexus.leops.local/repository/composer/; \
    composer config -gl; \
    composer config -g secure-http false; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log;

CMD ["/bin/bash", "-c", "/usr/sbin/php-fpm${PHP_VERSION} --nodaemonize --fpm-config=/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"]
