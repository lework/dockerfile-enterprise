#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/tools/python:3

ARG ANSIBLE_VERSION=11.5.0

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/runtime/ansible/Dockerfile" \
      org.opencontainers.image.description="Minimal base runtime for ansible applications with non-root user."

RUN \
    set -exu; \
    groupadd -r nonroot; \
    useradd -r -m -g nonroot nonroot; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            openssl \
            openssh-client; \
    pip3 install --no-cache-dir ansible==${ANSIBLE_VERSION}; \
    ansible --version; \
    mkdir /etc/ansible; \
    ansible-config init --disabled -t all > /etc/ansible/ansible.cfg; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log;

USER nonroot:nonroot
