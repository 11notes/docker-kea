# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_GO_VERSION=0

# APP
  ARG BUILD_SRC=https://gitlab.isc.org/isc-projects/kea.git \
      BUILD_ROOT=/kea \
      BUILD_BIN=/kea/build/src/bin/dhcp4/kea-dhcp4

  # :: FOREIGN IMAGES
  FROM 11notes/distroless:openssl AS distroless-openssl
  FROM 11notes/util:bin AS util-bin


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: ENTRYPOINT
  FROM 11notes/go:${APP_GO_VERSION} AS entrypoint
  ARG APP_GO_VERSION
  COPY ./build/go/entrypoint /go/entrypoint
  RUN set -ex; \
    cd /go/entrypoint; \
    go mod edit -go=${APP_GO_VERSION}; \
    eleven go build /entrypoint main.go; \
    eleven distroless /entrypoint;


# :: HEALTHCHECK
  FROM 11notes/go:${APP_GO_VERSION} AS healthcheck
  ARG APP_GO_VERSION
  COPY ./build/go/healthcheck /go/healthcheck
  RUN set -ex; \
    cd /go/healthcheck; \
    go mod edit -go=${APP_GO_VERSION}; \
    eleven go build /healthcheck main.go;


# :: KEA
  FROM alpine AS build
  COPY --from=util-bin / /
  ARG TARGETARCH \
      TARGETVARIANT \
      APP_VERSION \
      APP_ROOT \
      BUILD_SRC \
      BUILD_ROOT \
      BUILD_BIN

  RUN set -ex; \ 
    apk add --update --no-cache \
      build-base \
      gcc \
      g++ \
      meson \
      ninja \
      pkgconf \
      git \
      openssl-dev \
      log4cplus-dev \
      boost-dev;

  RUN set -ex; \
    git clone ${BUILD_SRC} -b Kea-${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    meson setup build \
      --prefix=/usr \
      --buildtype=release \
      -Dstrip=true \
      -Dmysql=disabled \
      -Dpostgresql=disabled \
      -Dkrb5=disabled \
      -Dnetconf=disabled \
      -Dtests=disabled;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    meson compile -C build; \
    DESTDIR=/opt/kea meson install -C build; \
    rm -rf /opt/kea/var/run; \
    mkdir -p /opt/kea/run;

  RUN set -ex; \
    rm -rf \
      /opt/kea/usr/include \
      /opt/kea/usr/share/doc \
      /opt/kea/usr/share/man \
      /opt/kea/usr/lib/*.a;


# FILE SYSTEM
  FROM alpine AS file-system
  RUN set -ex; \
    mkdir -p /distroless/kea/etc; \
    mkdir -p /distroless/kea/var; \
    mkdir -p /distroless/kea/run;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM 11notes/alpine:stable

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV KEA_CONTROL_SOCKET_DIR="/kea/run" \
        KEA_DHCP_DATA_DIR="/kea/var" \
        KEA_PIDFILE_DIR="/kea/run" \
        KEA_LOCKFILE_DIR="/kea/run" \
        KEA_INTERFACES="[\"*\"]"

  # :: multi-stage
    COPY --from=distroless-openssl / /
    COPY --from=entrypoint /distroless/ /
    COPY --from=healthcheck /healthcheck /usr/local/bin/healthcheck
    COPY --from=build /opt/kea /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: SETUP
  USER root

  RUN set -ex; \
    apk --update --no-cache add \
      libstdc++ \
      libgcc \
      boost-system \
      openssl \
      log4cplus; \
    apk --update --no-cache --virtual .caps add \
      libcap; \
    setcap cap_net_bind_service,cap_net_raw=+ep /usr/sbin/kea-dhcp4; \
    apk --no-network del .caps;

# :: HEALTH
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/healthcheck"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/entrypoint"]