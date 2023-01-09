# syntax=docker/dockerfile:1

ARG LIBSIG_VERSION=3.0.3
ARG CARES_VERSION=1.17.2
ARG CURL_VERSION=7.78.0
ARG XMLRPC_VERSION=01.58.00
ARG LIBTORRENT_VERSION=v0.13.8
ARG RTORRENT_VERSION=v0.9.8
ARG MKTORRENT_VERSION=v1.1
ARG GEOIP2_PHPEXT_VERSION=1.3.1

# v4.0-stable
ARG RUTORRENT_VERSION=06222a00375bdd0f1f1b5b58bda29e7025316428
ARG GEOIP2_RUTORRENT_VERSION=4ff2bde530bb8eef13af84e4413cedea97eda148

ARG ALPINE_VERSION=3.17
ARG ALPINE_S6_VERSION=${ALPINE_VERSION}-2.2.0.3

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS src
RUN apk --update --no-cache add curl git subversion tar tree xz
WORKDIR /src

FROM src AS src-libsig
ARG LIBSIG_VERSION
RUN curl -sSL "http://ftp.gnome.org/pub/GNOME/sources/libsigc++/3.0/libsigc++-${LIBSIG_VERSION}.tar.xz" | tar xJv --strip 1

FROM src AS src-cares
ARG CARES_VERSION
RUN curl -sSL "https://c-ares.haxx.se/download/c-ares-${CARES_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-xmlrpc
ARG XMLRPC_VERSION
RUN <<EOT
git clone https://github.com/crazy-max/xmlrpc-c.git .
git reset --hard $XMLRPC_VERSION
EOT

FROM src AS src-curl
ARG CURL_VERSION
RUN curl -sSL "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-libtorrent
ARG LIBTORRENT_VERSION
RUN <<EOT
git clone https://github.com/rakshasa/libtorrent.git .
git reset --hard $LIBTORRENT_VERSION
EOT

FROM src AS src-rtorrent
ARG RTORRENT_VERSION
RUN <<EOT
git clone https://github.com/rakshasa/rtorrent.git .
git reset --hard $RTORRENT_VERSION
EOT

FROM src AS src-mktorrent
ARG MKTORRENT_VERSION
RUN <<EOT
git clone https://github.com/esmil/mktorrent.git .
git reset --hard $MKTORRENT_VERSION
EOT

FROM src AS src-geoip2-phpext
ARG GEOIP2_PHPEXT_VERSION
RUN <<EOT
git clone https://github.com/rlerdorf/geoip.git .
git reset --hard $GEOIP2_PHPEXT_VERSION
EOT

FROM src AS src-rutorrent
ARG RUTORRENT_VERSION
RUN <<EOT
git clone https://github.com/Novik/ruTorrent.git .
git reset --hard $RUTORRENT_VERSION
rm -rf .git* conf/users plugins/geoip share
EOT

FROM src AS src-geoip2-rutorrent
ARG GEOIP2_RUTORRENT_VERSION
RUN <<EOT
git clone https://github.com/Micdu70/geoip2-rutorrent .
git reset --hard $GEOIP2_RUTORRENT_VERSION
rm -rf .git*
EOT

FROM src AS src-mmdb
RUN curl -SsOL "https://github.com/crazy-max/geoip-updater/raw/mmdb/GeoLite2-City.mmdb" \
  && curl -SsOL "https://github.com/crazy-max/geoip-updater/raw/mmdb/GeoLite2-Country.mmdb"

FROM crazymax/alpine-s6:${ALPINE_S6_VERSION} AS builder
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
    php81-dev \
    php81-pear \
    tar \
    tree \
    xz \
    zlib-dev

ENV DIST_PATH="/dist"

WORKDIR /usr/local/src/libsig
COPY --from=src-libsig /src .
RUN ./configure
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/cares
COPY --from=src-cares /src .
RUN ./configure
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/curl
COPY --from=src-curl /src .
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

WORKDIR /usr/local/src/xmlrpc
COPY --from=src-xmlrpc /src .
RUN ./configure \
   --disable-wininet-client \
   --disable-libwww-client
RUN make -j$(nproc)
RUN make install -j$(nproc) CXXFLAGS="-flto"
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/libtorrent
COPY --from=src-libtorrent /src .
RUN ./autogen.sh
RUN ./configure \
  --with-posix-fallocate
RUN make -j$(nproc)
RUN make install -j$(nproc) CXXFLAGS="-O2 -flto"
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/rtorrent
COPY --from=src-rtorrent /src .
RUN ./autogen.sh
RUN ./configure \
  --with-xmlrpc-c \
  --with-ncurses
RUN make -j$(nproc) CXXFLAGS="-O2 -flto"
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/mktorrent
COPY --from=src-mktorrent /src .
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

WORKDIR /usr/local/src/geoip2-phpext
COPY --from=src-geoip2-phpext /src .
RUN <<EOT
  set -e
  phpize81
  ./configure
  make
  make install
EOT
RUN mkdir -p ${DIST_PATH}/usr/lib/php81/modules
RUN cp -f /usr/lib/php81/modules/geoip.so ${DIST_PATH}/usr/lib/php81/modules/
RUN tree ${DIST_PATH}

FROM crazymax/alpine-s6:${ALPINE_S6_VERSION}
COPY --from=builder /dist /
COPY --from=src-rutorrent --chown=nobody:nogroup /src /var/www/rutorrent
COPY --from=src-geoip2-rutorrent --chown=nobody:nogroup /src /var/www/rutorrent/plugins/geoip2
COPY --from=src-mmdb /src /var/mmdb

ENV PYTHONPATH="$PYTHONPATH:/var/www/rutorrent" \
  S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  S6_KILL_GRACETIME="10000" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

# unrar package is not available since alpine 3.15
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
    dhclient \
    ffmpeg \
    findutils \
    geoip \
    grep \
    gzip \
    libstdc++ \
    mediainfo \
    ncurses \
    nginx \
    nginx-mod-http-dav-ext \
    nginx-mod-http-geoip2 \
    openssl \
    php81 \
    php81-bcmath \
    php81-cli \
    php81-ctype \
    php81-curl \
    php81-fpm \
    php81-json \
    php81-mbstring \
    php81-openssl \
    php81-phar \
    php81-posix \
    php81-session \
    php81-sockets \
    php81-xml \
    php81-zip \
    php81-zlib \
    python3 \
    py3-pip \
    shadow \
    sox \
    tar \
    tzdata \
    unzip \
    util-linux \
    zip \
  && pip3 install --upgrade pip \
  && pip3 install cfscrape cloudscraper \
  && addgroup -g ${PGID} rtorrent \
  && adduser -D -H -u ${PUID} -G rtorrent -s /bin/sh rtorrent \
  && curl --version \
  && rm -rf /tmp/*

COPY rootfs /

VOLUME [ "/data", "/downloads", "/passwd" ]
ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
  CMD /usr/local/bin/healthcheck
