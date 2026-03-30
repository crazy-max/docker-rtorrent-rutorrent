# syntax=docker/dockerfile:1

ARG CARES_VERSION=1.34.8
ARG CURL_VERSION=8.21.0

ARG LIBTORRENT_VERSION=v0.16.25
ARG RTORRENT_VERSION=v0.16.25

ARG MKTORRENT_VERSION=v1.1

ARG RUTORRENT_VERSION=v5.3.16
ARG DUMPTORRENT_VERSION=v1.7.0

ARG ALPINE_VERSION=3.24

FROM tianon/gosu:latest AS gosu

FROM --platform=${BUILDPLATFORM} alpine:${ALPINE_VERSION} AS src
RUN apk --update --no-cache add curl git tar tree sed xz
WORKDIR /src

FROM src AS src-cares
ARG CARES_VERSION
RUN curl -sSL "https://github.com/c-ares/c-ares/releases/download/v${CARES_VERSION}/c-ares-${CARES_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-curl
ARG CURL_VERSION
RUN curl -sSL "https://curl.se/download/curl-${CURL_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-libtorrent
RUN git init . && git remote add origin "https://github.com/rakshasa/libtorrent.git"
ARG LIBTORRENT_VERSION
RUN git fetch origin "${LIBTORRENT_VERSION}" && git checkout -q FETCH_HEAD

FROM src AS src-rtorrent
RUN git init . && git remote add origin "https://github.com/rakshasa/rtorrent.git"
ARG RTORRENT_VERSION
RUN git fetch origin "${RTORRENT_VERSION}" && git checkout -q FETCH_HEAD

FROM src AS src-mktorrent
RUN git init . && git remote add origin "https://github.com/pobrn/mktorrent.git"
ARG MKTORRENT_VERSION
RUN git fetch origin "${MKTORRENT_VERSION}" && git checkout -q FETCH_HEAD

FROM src AS src-rutorrent
RUN git init . && git remote add origin "https://github.com/Novik/ruTorrent.git"
ARG RUTORRENT_VERSION
RUN git fetch origin "${RUTORRENT_VERSION}" && git checkout -q FETCH_HEAD
RUN rm -rf .git* conf/users plugins/geoip share tests

FROM composer:2 AS update-geoip2-rutorrent
WORKDIR /app
COPY geoip2-rutorrent/composer.json ./
RUN composer update --no-dev --no-interaction --no-progress --prefer-dist --classmap-authoritative

FROM scratch AS export-geoip2-rutorrent
COPY --from=update-geoip2-rutorrent /app/composer.json /composer.json
COPY --from=update-geoip2-rutorrent /app/composer.lock /composer.lock
COPY --from=update-geoip2-rutorrent /app/vendor /vendor

FROM composer:2 AS vendor-geoip2-rutorrent
WORKDIR /app
COPY geoip2-rutorrent/composer.json geoip2-rutorrent/composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --classmap-authoritative

FROM src AS src-geoip2-rutorrent
COPY geoip2-rutorrent /src
COPY --from=vendor-geoip2-rutorrent /app/vendor /src/vendor

FROM src AS src-mmdb
RUN curl -SsOL "https://github.com/crazy-max/geoip-updater/raw/mmdb/GeoLite2-City.mmdb" \
  && curl -SsOL "https://github.com/crazy-max/geoip-updater/raw/mmdb/GeoLite2-Country.mmdb"

FROM src AS src-dumptorrent
RUN git init . && git remote add origin "https://github.com/tomcdj71/dumptorrent.git"
ARG DUMPTORRENT_VERSION
RUN git fetch origin "${DUMPTORRENT_VERSION}" && git checkout -q FETCH_HEAD
RUN sed -i '1i #include <sys/time.h>' src/scrapec.c
RUN rm -rf .git*

FROM alpine:${ALPINE_VERSION} AS builder
RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    brotli-dev \
    build-base \
    cppunit-dev \
    cmake \
    gd-dev \
    libpsl-dev \
    libsigc++3-dev \
    libtool \
    libxslt-dev \
    linux-headers \
    ncurses-dev \
    nghttp2-dev \
    openssl-dev \
    pcre-dev \
    php85-dev \
    php85-pear \
    tar \
    tree \
    xz \
    zlib-dev

ENV DIST_PATH="/dist"

WORKDIR /usr/local/src/cares
COPY --from=src-cares /src .
RUN cmake . -D CARES_SHARED=ON -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_C_FLAGS_RELEASE:STRING="-O3 -flto=\"$(nproc)\" -pipe"
RUN cmake --build . --clean-first --parallel $(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/curl
COPY --from=src-curl /src .
RUN cmake . -D ENABLE_ARES=ON -D CURL_LTO=ON -D CURL_USE_OPENSSL=ON -D CURL_BROTLI=ON -D CURL_ZSTD=ON -D BUILD_SHARED_LIBS=ON -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_C_FLAGS_RELEASE:STRING="-O3 -flto=\"$(nproc)\" -pipe"
RUN cmake --build . --clean-first --parallel $(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/libtorrent
COPY --from=src-libtorrent /src .
RUN autoreconf -vfi
RUN ./configure --enable-aligned --enable-ipv6
RUN make -j$(nproc) CXXFLAGS="-w -O3 -flto -Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/rtorrent
COPY --from=src-rtorrent /src .
RUN autoreconf -vfi
RUN ./configure --with-xmlrpc-tinyxml2 --with-ncurses --enable-ipv6
RUN make -j$(nproc) CXXFLAGS="-w -O3 -flto -Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/mktorrent
COPY --from=src-mktorrent /src .
RUN echo "CC = gcc" >> Makefile
RUN echo "CFLAGS = -w -flto -O3" >> Makefile
RUN echo "USE_PTHREADS = 1" >> Makefile
RUN echo "USE_OPENSSL = 1" >> Makefile
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/dumptorrent
COPY --from=src-dumptorrent /src .
RUN cmake -B build/ -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE=Release -S .
RUN cmake --build build/ --config Release --parallel $(nproc)
RUN cp build/dumptorrent build/scrapec ${DIST_PATH}/usr/local/bin
RUN tree ${DIST_PATH}

FROM alpine:${ALPINE_VERSION}
COPY --from=gosu /gosu /usr/local/bin/
COPY --from=builder /dist /
COPY --from=src-rutorrent --chown=nobody:nogroup /src /var/www/rutorrent
COPY --from=src-geoip2-rutorrent --chown=nobody:nogroup /src /var/www/rutorrent/plugins/geoip2
COPY --from=src-mmdb /src /var/mmdb

ENV PYTHONPATH="/var/www/rutorrent" \
  S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  S6_STAGE2_HOOK="/etc/s6-overlay/scripts/runtime-bundles" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

# increase rmem_max and wmem_max for rTorrent configuration
RUN echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf \
  && echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf \
  && sysctl -p

# ruTorrent's unpack plugin requires unrar, which Alpine removed in 3.15.
# Use the last Alpine release that packaged it until a replacement is available.
RUN echo "@314 http://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories \
  && apk --update --no-cache add unrar@314

RUN apk --update --no-cache add \
    apache2-utils \
    bash \
    bind-tools \
    binutils \
    brotli \
    ca-certificates \
    coreutils \
    ffmpeg \
    findutils \
    grep \
    gzip \
    libsigc++3 \
    libstdc++ \
    mediainfo \
    ncurses \
    nginx \
    nginx-mod-http-dav-ext \
    nginx-mod-http-geoip2 \
    openssl \
    php85 \
    php85-bcmath \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-fileinfo \
    php85-fpm \
    php85-mbstring \
    php85-openssl \
    php85-posix \
    php85-session \
    php85-simplexml \
    php85-sockets \
    php85-xml \
    php85-zip \
    python3 \
    py3-pip \
    s6-overlay \
    shadow \
    sox \
    tar \
    tzdata \
    unzip \
    util-linux \
    zip \
  && pip3 install --upgrade --break-system-packages pip \
  && pip3 install --break-system-packages cfscrape cloudscraper \
  && addgroup -g ${PGID} rtorrent \
  && adduser -D -H -u ${PUID} -G rtorrent -s /bin/sh rtorrent \
  && curl --version \
  && rm -rf /tmp/*

COPY rootfs /

VOLUME [ "/data", "/downloads", "/passwd" ]
ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
  CMD /usr/local/bin/healthcheck
