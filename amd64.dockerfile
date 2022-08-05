# :: Build
	FROM alpine:3.16 as builder
	ENV keaVersion=2.2.0
    ENV logVersion=2.0.8

    RUN set -ex; \
        apk add --update --no-cache \
			alpine-sdk \
            bash \
            boost-dev \
            bzip2-dev \
            file \
            libressl-dev \
            mariadb-dev \
            zlib-dev \
            curl; \
        curl -sL https://sourceforge.net/projects/log4cplus/files/log4cplus-stable/${logVersion}/log4cplus-${logVersion}.tar.gz | tar -zx -C /tmp; \
        cd /tmp/log4cplus-${logVersion}; \
        ./configure; \
        make -s -j$(nproc); \
        make install; \
        curl -sL https://ftp.isc.org/isc/kea/${keaVersion}/kea-${keaVersion}.tar.gz | tar -zx -C /tmp; \
        cd /tmp/kea-${keaVersion}; \
        ./configure \
            --enable-shell \
            --with-dhcp-mysql=/usr/bin/mysql_config; \
        make -s -j$(nproc); \
        make install-strip;

# :: Header
	FROM alpine:3.16
	COPY --from=builder /usr/local /usr/local/

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /kea; \
            mkdir -p /kea/etc;

		RUN set -ex; \
			apk add --update --no-cache \
				bash \
                boost \
                bzip2 \
                libressl \
                mariadb-dev \
                mariadb-client \
                zlib \
                curl;

    # :: copy root filesystem changes
        COPY ./rootfs /

# :: Volumes
	VOLUME ["/kea/etc"]

# :: Monitor
    RUN set -ex; chmod +x /usr/local/bin/healthcheck.sh
    HEALTHCHECK --interval=5s --timeout=2s CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]