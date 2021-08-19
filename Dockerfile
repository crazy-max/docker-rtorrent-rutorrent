ARG ALPINE_S6_TAG=3.14-2.2.0.3
ARG RTORRENT_VERSION=0.9.8
ARG LIBTORRENT_VERSION=0.13.8
ARG XMLRPC_VERSION=01.58.00
ARG LIBSIG_VERSION=3.0.3
ARG CARES_VERSION=1.17.2
ARG CURL_VERSION=7.78.0
ARG MKTORRENT_VERSION=1.1
ARG RUTORRENT_VERSION=3.10
ARG RUTORRENT_REVISION=954479ffd00eb58ad14f9a667b3b9b1e108e80a2
ARG GEOIP2_PHPEXT_VERSION=1.1.1
ARG NGINX_VERSION=1.21.1
ARG NGINX_DAV_VERSION=3.0.0
ARG NGINX_UID=102
ARG NGINX_GID=102

FROM --platform=${BUILDPLATFORM:-linux/amd64} crazymax/alpine-s6:${ALPINE_S6_TAG} AS download
RUN apk --update --no-cache add curl git subversion tar tree xz

ARG XMLRPC_VERSION
WORKDIR /dist/xmlrpc-c
RUN svn checkout "http://svn.code.sf.net/p/xmlrpc-c/code/release_number/${XMLRPC_VERSION}/" .

ARG LIBSIG_VERSION
WORKDIR /dist/libsigc
RUN curl -SsOL "http://ftp.gnome.org/pub/GNOME/sources/libsigc++/3.0/libsigc++-${LIBSIG_VERSION}.tar.xz" \
  && unxz "libsigc++-${LIBSIG_VERSION}.tar.xz" \
  && tar -xf "libsigc++-${LIBSIG_VERSION}.tar" --strip 1 \
  && rm -f "libsigc++-${LIBSIG_VERSION}.tar.xz" "libsigc++-${LIBSIG_VERSION}.tar"

ARG CARES_VERSION
WORKDIR /dist/c-ares
RUN curl -sSL "https://c-ares.haxx.se/download/c-ares-${CARES_VERSION}.tar.gz" | tar xz --strip 1

ARG CURL_VERSION
WORKDIR /dist/curl
RUN curl -sSL "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" | tar xz --strip 1

ARG LIBTORRENT_VERSION
WORKDIR /dist/libtorrent
RUN git clone --branch v${LIBTORRENT_VERSION} "https://github.com/rakshasa/libtorrent.git" .

ARG RTORRENT_VERSION
WORKDIR /dist/rtorrent
RUN git clone --branch v${RTORRENT_VERSION} "https://github.com/rakshasa/rtorrent.git" .

ARG MKTORRENT_VERSION
WORKDIR /dist/mktorrent
RUN git clone --branch v${MKTORRENT_VERSION} "https://github.com/esmil/mktorrent.git" .

ARG RUTORRENT_REVISION
WORKDIR /dist/rutorrent
RUN git clone "https://github.com/Novik/ruTorrent.git" . \
  && git reset --hard $RUTORRENT_REVISION \
  && rm -rf .git* conf/users plugins/geoip share

WORKDIR /dist/geoip2-rutorrent
RUN git clone "https://github.com/Micdu70/geoip2-rutorrent" . \
  && rm -rf .git*

WORKDIR /dist/mmdb
RUN curl -SsOL "https://github.com/crazy-max/geoip-updater/raw/mmdb/GeoLite2-City.mmdb" \
  && curl -SsOL "https://github.com/crazy-max/geoip-updater/raw/mmdb/GeoLite2-Country.mmdb"

ARG GEOIP2_PHPEXT_VERSION
WORKDIR /dist/geoip-ext
RUN curl -SsL "https://pecl.php.net/get/geoip-${GEOIP2_PHPEXT_VERSION}.tgz" -o "geoip.tgz"

ARG NGINX_VERSION
ARG NGINX_DAV_VERSION
WORKDIR /dist/nginx
RUN curl -sSL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar xz --strip 1
RUN git clone --branch v${NGINX_DAV_VERSION} "https://github.com/arut/nginx-dav-ext-module.git" nginx-dav-ext

ARG ALPINE_S6_TAG
FROM crazymax/alpine-s6:${ALPINE_S6_TAG} AS builder

RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    brotli-dev \
    build-base \
    cppunit-dev \
    gd-dev \
    geoip-dev \
    libtool \
    libxslt-dev \
    linux-headers \
    ncurses-dev \
    nghttp2-dev \
    openssl-dev \
    pcre-dev \
    php7-dev \
    php7-pear \
    tar \
    tree \
    xz \
    zlib-dev

ENV DIST_PATH="/dist"
COPY --from=download /dist /tmp

WORKDIR /tmp/libsigc
RUN ./configure
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/c-ares
RUN ./configure
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/curl
RUN ./configure \
  --enable-ares \
  --enable-tls-srp \
  --enable-gnu-tls \
  --with-brotli \
  --with-ssl \
  --with-zlib
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/xmlrpc-c
RUN ./configure
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/libtorrent
RUN ./autogen.sh
RUN ./configure \
  --with-posix-fallocate
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/rtorrent
RUN ./autogen.sh
RUN ./configure \
  --with-xmlrpc-c \
  --with-ncurses
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/mktorrent
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

ARG NGINX_UID
ARG NGINX_GID
WORKDIR /tmp/nginx
RUN addgroup -g ${NGINX_UID} -S nginx
RUN adduser -S -D -H -u ${NGINX_GID} -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
RUN ./configure \
  --prefix=/usr/lib/nginx \
  --sbin-path=/sbin/nginx \
  --pid-path=/var/pid/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --http-log-path=/dev/stdout \
  --error-log-path=/dev/stderr \
  --pid-path=/var/pid/nginx.pid \
  --user=nginx \
  --group=nginx \
  --with-file-aio \
  --with-pcre-jit \
  --with-threads \
  --with-poll_module \
  --with-select_module \
  --with-stream_ssl_module \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_degradation_module \
  --with-http_flv_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-mail_ssl_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-mail=dynamic \
  --with-stream=dynamic \
  --with-http_geoip_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_xslt_module=dynamic \
  --add-dynamic-module=./nginx-dav-ext
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /tmp/geoip-ext
RUN pecl install geoip.tgz
RUN mkdir -p ${DIST_PATH}/usr/lib/php7/modules
RUN cp -f /usr/lib/php7/modules/geoip.so ${DIST_PATH}/usr/lib/php7/modules/
RUN tree ${DIST_PATH}

ARG ALPINE_S6_TAG
FROM crazymax/alpine-s6:${ALPINE_S6_TAG}

COPY --from=builder /dist /
COPY --from=download --chown=nobody:nogroup /dist/rutorrent /var/www/rutorrent
COPY --from=download --chown=nobody:nogroup /dist/geoip2-rutorrent /var/www/rutorrent/plugins/geoip2
COPY --from=download /dist/mmdb /var/mmdb

ENV PYTHONPATH="$PYTHONPATH:/var/www/rutorrent" \
  S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

ARG NGINX_UID
ARG NGINX_GID
RUN apk --update --no-cache add \
    apache2-utils \
    bash \
    bind-tools \
    binutils \
    brotli \
    ca-certificates \
    coreutils \
    dhclient \
    ffmpeg \
    findutils \
    geoip \
    grep \
    gzip \
    libstdc++ \
    mediainfo \
    ncurses \
    openssl \
    pcre \
    php7 \
    php7-bcmath \
    php7-cli \
    php7-ctype \
    php7-curl \
    php7-fpm \
    php7-json \
    php7-mbstring \
    php7-openssl \
    php7-phar \
    php7-posix \
    php7-session \
    php7-sockets \
    php7-xml \
    php7-zip \
    php7-zlib \
    python3 \
    py3-pip \
    shadow \
    sox \
    tar \
    tzdata \
    unrar \
    unzip \
    util-linux \
    zip \
    zlib \
  && ln -s /usr/lib/nginx/modules /etc/nginx/modules \
  && addgroup -g ${NGINX_UID} -S nginx \
  && adduser -S -D -H -u ${NGINX_GID} -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
  && pip3 install --upgrade pip \
  && pip3 install cfscrape cloudscraper \
  && addgroup -g ${PGID} rtorrent \
  && adduser -D -H -u ${PUID} -G rtorrent -s /bin/sh rtorrent \
  && curl --version \
  && rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /

VOLUME [ "/data", "/downloads", "/passwd" ]
ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
  CMD /usr/local/bin/healthcheck
