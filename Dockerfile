# syntax=docker/dockerfile:1

# renovate: datasource=custom.release-archive depName=c-ares/c-ares
ARG CARES_VERSION=1.34.9
ARG CARES_SHA256=9364b70a12eb59a06830fb488d9357f90100dff0d98b23ea3593a183d43e6f2f
# renovate: datasource=custom.release-archive depName=curl/curl
ARG CURL_VERSION=8.23.0
ARG CURL_SHA256=e3de77cfa6367083c776a26647fc9f633b538c06c3baa73d931a252ac8f72b49

# renovate: datasource=github-tags depName=rakshasa/libtorrent
ARG LIBTORRENT_VERSION=v0.16.28
ARG LIBTORRENT_COMMIT=392030e0fddbe4e423d059d9322382cf44aaaaf6
# renovate: datasource=github-tags depName=rakshasa/rtorrent
ARG RTORRENT_VERSION=v0.16.28
ARG RTORRENT_COMMIT=0c23d278a7838402d4cec9689bf71e051332be67

# renovate: datasource=github-tags depName=pobrn/mktorrent
ARG MKTORRENT_VERSION=v1.1
ARG MKTORRENT_COMMIT=b20ef699b4ee5ded2f078ead776c7deac969e19a

# renovate: datasource=github-tags depName=Novik/ruTorrent
ARG RUTORRENT_VERSION=v5.3.25
ARG RUTORRENT_COMMIT=91f966a01bc35a25598ce7f024855625113b31d7
# renovate: datasource=github-tags depName=tomcdj71/dumptorrent
ARG DUMPTORRENT_VERSION=v1.7.0
ARG DUMPTORRENT_COMMIT=ddf988d3099637c93dc0247854ca711c0a2a0289
# renovate: datasource=custom.unrar depName=unrar
ARG UNRAR_VERSION=7.3.2

# renovate: datasource=docker depName=alpine versioning=docker
ARG ALPINE_VERSION=3.24

FROM tianon/gosu:latest AS gosu

FROM --platform=${BUILDPLATFORM} alpine:${ALPINE_VERSION} AS src
RUN apk --update --no-cache add tar tree sed xz
WORKDIR /src

FROM src AS src-cares
ARG CARES_VERSION
ARG CARES_SHA256
ADD --checksum=sha256:${CARES_SHA256} "https://github.com/c-ares/c-ares/releases/download/v${CARES_VERSION}/c-ares-${CARES_VERSION}.tar.gz" /tmp/source.tar.gz
RUN tar xzf /tmp/source.tar.gz --strip 1

FROM src AS src-curl
ARG CURL_VERSION
ARG CURL_SHA256
ADD --checksum=sha256:${CURL_SHA256} "https://curl.se/download/curl-${CURL_VERSION}.tar.gz" /tmp/source.tar.gz
RUN tar xzf /tmp/source.tar.gz --strip 1

FROM src AS src-libtorrent
ARG LIBTORRENT_VERSION
ARG LIBTORRENT_COMMIT
ADD --checksum=${LIBTORRENT_COMMIT} "https://github.com/rakshasa/libtorrent.git#${LIBTORRENT_VERSION}" .

FROM src AS src-rtorrent
ARG RTORRENT_VERSION
ARG RTORRENT_COMMIT
ADD --checksum=${RTORRENT_COMMIT} "https://github.com/rakshasa/rtorrent.git#${RTORRENT_VERSION}" .

FROM src AS src-mktorrent
ARG MKTORRENT_VERSION
ARG MKTORRENT_COMMIT
ADD --checksum=${MKTORRENT_COMMIT} "https://github.com/pobrn/mktorrent.git#${MKTORRENT_VERSION}" .

FROM src AS src-rutorrent
ARG RUTORRENT_VERSION
ARG RUTORRENT_COMMIT
ADD --checksum=${RUTORRENT_COMMIT} "https://github.com/Novik/ruTorrent.git#${RUTORRENT_VERSION}" .
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
ADD --chmod=0644 "https://raw.githubusercontent.com/crazy-max/geoip-updater/mmdb/GeoLite2-City.mmdb" ./GeoLite2-City.mmdb
ADD --chmod=0644 "https://raw.githubusercontent.com/crazy-max/geoip-updater/mmdb/GeoLite2-Country.mmdb" ./GeoLite2-Country.mmdb

FROM src AS src-dumptorrent
ARG DUMPTORRENT_VERSION
ARG DUMPTORRENT_COMMIT
ADD --checksum=${DUMPTORRENT_COMMIT} "https://github.com/tomcdj71/dumptorrent.git#${DUMPTORRENT_VERSION}" .
RUN sed -i '1i #include <sys/time.h>' src/scrapec.c
RUN rm -rf .git*

FROM src AS src-unrar
ARG UNRAR_VERSION
ADD "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" /tmp/source.tar.gz
RUN tar xzf /tmp/source.tar.gz --strip 1

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
RUN ./configure --enable-aligned
RUN make -j$(nproc) CXXFLAGS="-w -O3 -flto -Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/rtorrent
COPY --from=src-rtorrent /src .
RUN autoreconf -vfi
RUN ./configure --with-xmlrpc-tinyxml2 --with-ncurses
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

WORKDIR /usr/local/src/unrar
COPY --from=src-unrar /src .
RUN make CXXFLAGS="-O2" LDFLAGS="-pthread"
RUN install -D -m 755 unrar ${DIST_PATH}/usr/local/bin/unrar
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
