#syntax=harbor.leops.local/library/docker/dockerfile:1

ARG OS_VERSION=bullseye-slim

FROM debian:$OS_VERSION

ARG OS_VERSION

LABEL org.opencontainers.image.authors="ops.leops.local" \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/os/debian/bullseye-slim/Dockerfile" \
      org.opencontainers.image.description="Standard Debian $OS_VERSION base image for internal use."

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TZ='Asia/Shanghai' \
    OS_VERSION=$OS_VERSION

WORKDIR /app

RUN sed -i -e 's#deb.debian.org#mirrors.aliyun.com#g' \
           -e 's#security.debian.org#mirrors.aliyun.com#g' \
           -e 's#ftp.debian.org#mirrors.aliyun.com#g' \
           /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y --only-upgrade $(apt-get --just-print upgrade | awk 'tolower($4) ~ /.*security.*/ || tolower($5) ~ /.*security.*/ {print $2}' | sort | uniq)  \
  && DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes apt-get install -y --no-install-recommends \
                        ca-certificates openssl \
                        tzdata wget curl procps psmisc dnsutils iproute2 telnet vim-tiny zip unzip inetutils-ping tcpdump lsof \
                        net-tools traceroute strace fonts-noto-cjk fontconfig locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8 \
  && fc-cache \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log \
  && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
  && echo ${TZ} > /etc/timezone \
  && echo 'export PS1="\e[1;34m[\e[1;33m\u@\e[1;32m\h\e[1;37m:\w\[\e[1;34m]\e[1;36m\\$ \e[0m"' >> /etc/bash.bashrc \
  && echo 'transfer(){ if [ $# -eq 0 ];then echo "No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>">&2;return 1;fi;if tty -s;then file="$1";file_name=$(basename "$file");if [ ! -e "$file" ];then echo "$file: No such file or directory">&2;return 1;fi;if [ -d "$file" ];then file_name="$file_name.zip" ,;(cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "http://transfer.leops.local/$file_name"|tee /dev/null,;else cat "$file"|curl --progress-bar --upload-file "-" "http://transfer.leops.local/$file_name"|tee /dev/null;fi;else file_name=$1;curl --progress-bar --upload-file "-" "http://transfer.leops.local/$file_name"|tee /dev/null;fi;echo;}' >> /etc/bash.bashrc
