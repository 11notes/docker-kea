# :: QEMU
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM --platform=linux/arm64 11notes/alpine:arm64v8-stable as build
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  ENV BUILD_VERSION=2.6.0
  ENV BUILD_DIR=/kea

  USER root

  RUN set -ex; \
    apk add --no-cache --update \
      openssl-dev \
      mariadb-dev \
      postgresql-dev \
      log4cplus-dev \
      libstdc++-dev \
      python3-dev \
      botan-dev \
      krb5-dev \
      procps \
      bison \
      flex \
      libcap-utils \
      libtool \
      boost-dev \
      autoconf \
      automake \
      libtool \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      g++ \
      git;
  RUN set -ex; \
    git clone https://gitlab.isc.org/isc-projects/kea.git; \
    cd ${BUILD_DIR}; \
    git checkout Kea-${BUILD_VERSION};
  RUN set -ex; \
    cd ${BUILD_DIR}; \
    autoreconf --install; \
    ./configure \
      --disable-rpath \
      --disable-shared \
      --enable-static=yes \
      --enable-static-link=yes \
      --disable-install-configurations \
      --prefix=/opt/kea \
      --with-openssl \
      --with-mysql \
      --with-pgsql; \
    make -s -j$(nproc);
  RUN set -ex; \
    cd ${BUILD_DIR}; \
    make install-strip;

# :: Header
  FROM --platform=linux/arm64 11notes/alpine:arm64v8-stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /opt/kea /opt/kea
  ENV APP_NAME="kea"
  ENV APP_ROOT=/kea

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      apk add --no-cache --update \
        libcap \
        mariadb-connector-c \
        libpq-dev \
        libstdc++-dev \
        log4cplus-dev; \
      apk --no-cache upgrade; \
      ln -s /opt/kea/var/run/kea ${APP_ROOT}/run;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin;

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        /opt/kea \
        ${APP_ROOT};

    RUN set -ex; \
      setcap cap_net_bind_service,cap_net_raw=+ep /opt/kea/sbin/kea-dhcp4;

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]