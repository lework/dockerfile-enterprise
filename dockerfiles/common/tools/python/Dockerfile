#syntax=harbor.leops.local/library/docker/dockerfile:1

FROM harbor.leops.local/common/os/debian:bullseye

ARG PYTHON_VERSION=3.11.12

LABEL org.opencontainers.image.authors="ops@leops.local"  \
      org.opencontainers.image.source="http://git.leops.local/ops/dockerfiles-base/common/tools/openjdk/Dockerfile" \
      org.opencontainers.image.description="python ${PYTHON_VERSION} compiler environment."

ENV LANG=C.UTF-8 \
    PATH=/usr/local/bin:$PATH \
    PYTHON_VERSION=$PYTHON_VERSION \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_TRUSTED_HOST=nexus.leops.local \
    PIP_INDEX_URL=http://nexus.leops.local/repository/pypi-group/simple

# install dependencies
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends  \
               build-essential \
               default-libmysqlclient-dev \
               libreadline-dev \
               libncursesw5-dev \
               libssl-dev \
               libsqlite3-dev \
               libgdbm-dev \
               libc6-dev \
               libbz2-dev \
               libffi-dev \
               zlib1g-dev \
               libbluetooth-dev \
               tk-dev \
               uuid-dev \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# install python
RUN set -eux; \
	\
	wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
	mkdir -p /usr/src/python; \
	tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; \
	rm python.tar.xz; \
	\
	cd /usr/src/python; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-lto \
		--with-ensurepip \
	; \
	nproc="$(nproc)"; \
	EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
	make -j "$nproc" \
		"EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
		"LDFLAGS=${LDFLAGS:-}" \
	; \
# https://github.com/docker-library/python/issues/784
# prevent accidental usage of a system installed libpython of the same version
	rm python; \
	make -j "$nproc" \
		"EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
		"LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
		python \
	; \
	make install; \
	\
# enable GDB to load debugging data: https://github.com/docker-library/python/pull/701
	bin="$(readlink -ve /usr/local/bin/python3)"; \
	dir="$(dirname "$bin")"; \
	mkdir -p "/usr/share/gdb/auto-load/$dir"; \
	cp -vL Tools/gdb/libpython.py "/usr/share/gdb/auto-load/$bin-gdb.py"; \
	\
	cd /; \
	rm -rf /usr/src/python; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
		\) -exec rm -rf '{}' + \
	; \
	\
	ldconfig; \
	\
	export PYTHONDONTWRITEBYTECODE=1; \
	python3 --version; \
	\
	pip3 install \
		--disable-pip-version-check \
		--no-cache-dir \
		--no-compile \
		'setuptools==65.5.1' \
		# https://github.com/docker-library/python/issues/1023
		'wheel<0.46' \
	; \
	pip3 --version; \
	for src in idle3 pip3 pydoc3 python3 python3-config; do \
		dst="$(echo "$src" | tr -d 3)"; \
		[ -s "/usr/local/bin/$src" ]; \
		[ ! -e "/usr/local/bin/$dst" ]; \
		ln -svT "$src" "/usr/local/bin/$dst"; \
	done

CMD ["python3"]

