FROM nginx:mainline-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/crazy-max/docker-rtorrent-rutorrent" \
  org.opencontainers.image.source="https://github.com/crazy-max/docker-rtorrent-rutorrent" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.vendor="CrazyMax" \
  org.opencontainers.image.title="rTorrent and ruTorrent" \
  org.opencontainers.image.description="rTorrent and ruTorrent" \
  org.opencontainers.image.licenses="MIT"

ENV RTORRENT_VERSION=0.9.8 \
  LIBTORRENT_VERSION=0.13.8 \
  XMLRPC_VERSION=01.58.00 \
  LIBSIG_VERSION=3.0.3 \
  CARES_VERSION=1.14.0 \
  CURL_VERSION=7.71.0 \
  MKTORRENT_VERSION=1.1 \
  NGINX_DAV_VERSION=3.0.0

RUN apk --update --no-cache add -t build-dependencies \
    autoconf \
    automake \
    binutils \
    brotli-dev \
    build-base \
    c-ares-dev \
    cppunit-dev \
    git \
    libtool \
    linux-headers \
    ncurses-dev \
    nghttp2-dev \
    openssl-dev \
    subversion \
    tar \
    wget \
    xz \
    zlib-dev \
  # xmlrpc
  && cd /tmp \
  && svn checkout http://svn.code.sf.net/p/xmlrpc-c/code/release_number/${XMLRPC_VERSION}/ xmlrpc-c \
  && cd xmlrpc-c \
  && ./configure \
  && make \
  && make install \
  # libsig
  && cd /tmp \
  && wget http://ftp.gnome.org/pub/GNOME/sources/libsigc++/3.0/libsigc++-${LIBSIG_VERSION}.tar.xz \
  && unxz libsigc++-${LIBSIG_VERSION}.tar.xz \
  && tar -xf libsigc++-${LIBSIG_VERSION}.tar \
  && cd libsigc++-${LIBSIG_VERSION} \
  && ./configure \
  && make \
  && make install \
  # cares
  && cd /tmp \
  && wget https://c-ares.haxx.se/download/c-ares-${CARES_VERSION}.tar.gz \
  && tar zxf c-ares-${CARES_VERSION}.tar.gz \
  && cd c-ares-${CARES_VERSION} \
  && ./configure \
  && make \
  && make install \
  # curl
  && cd /tmp \
  && wget https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz \
  && tar zxf curl-${CURL_VERSION}.tar.gz \
  && cd curl-${CURL_VERSION} \
  && ./configure \
    --enable-ares \
    --enable-tls-srp \
    --enable-gnu-tls \
    --with-brotli \
    --with-ssl \
    --with-zlib \
  && make \
  && make install \
  # libtorrent
  && cd /tmp \
  && git clone https://github.com/rakshasa/libtorrent.git \
  && cd libtorrent \
  && git checkout tags/v${LIBTORRENT_VERSION} \
  && ./autogen.sh \
  && ./configure --with-posix-fallocate \
  && make \
  && make install \
  # rtorrent
  && cd /tmp \
  && git clone https://github.com/rakshasa/rtorrent.git \
  && cd rtorrent \
  && git checkout tags/v${RTORRENT_VERSION} \
  && ./autogen.sh \
  && ./configure --with-xmlrpc-c --with-ncurses \
  && make \
  && make install \
  # mktorrent
  && git clone https://github.com/esmil/mktorrent.git \
  && cd mktorrent \
  && git checkout tags/v${MKTORRENT_VERSION} \
  && make \
  && make install \
  && apk del build-dependencies \
  && rm -rf /tmp/* /var/cache/apk/*

ENV RUTORRENT_VERSION="3.10" \
  RUTORRENT_REVISION="3446d5a" \
  GEOIP_EXT_VERSION="1.1.1"

RUN apk --update --no-cache add \
    apache2-utils \
    bind-tools \
    binutils \
    brotli \
    ca-certificates \
    coreutils \
    dhclient \
    ffmpeg \
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
    php7-session \
    php7-sockets \
    php7-xml \
    php7-zip \
    php7-zlib \
    python3 \
    py3-pip \
    shadow \
    sox \
    su-exec \
    tar \
    tzdata \
    unrar \
    unzip \
    util-linux \
    wget \
    zip \
    zlib \
  && apk --update --no-cache add -t build-dependencies \
    brotli-dev \
    build-base \
    libxslt-dev \
    libxml2-dev \
    geoip-dev \
    git \
    libc-dev \
    libffi-dev \
    libressl-dev \
    linux-headers \
    openssl-dev \
    pcre-dev \
    php7-dev \
    php7-pear \
    python3-dev \
    zlib-dev \
  # s6-overlay
  && wget -q "https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz" -qO "/tmp/s6-overlay-amd64.tar.gz" \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  # nginx webdav
  && mkdir -p /usr/src \
  && cd /usr/src \
  && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
  && tar zxvf nginx-$NGINX_VERSION.tar.gz \
  && git clone -b v${NGINX_DAV_VERSION} --single-branch --depth 1 https://github.com/arut/nginx-dav-ext-module.git \
  && cd nginx-$NGINX_VERSION \
  && ./configure --with-compat --add-dynamic-module=../nginx-dav-ext-module \
  && make modules \
  && cp objs/ngx_http_dav_ext_module.so /etc/nginx/modules \
  # ruTorrent
  && mkdir -p /var/www \
  && cd /var/www \
  && git clone https://github.com/Novik/ruTorrent.git rutorrent \
  && cd rutorrent \
  && git checkout ${RUTORRENT_REVISION} \
  && pip3 install --upgrade pip \
  && pip3 install cfscrape cloudscraper \
  && git clone https://github.com/Micdu70/geoip2-rutorrent /var/www/rutorrent/plugins/geoip2 \
  # geolite2
  && mkdir /var/mmdb \
  && wget -q https://github.com/crazy-max/docker-matomo/raw/mmdb/GeoLite2-City.mmdb -qO /var/mmdb/GeoLite2-City.mmdb \
  && wget -q https://github.com/crazy-max/docker-matomo/raw/mmdb/GeoLite2-Country.mmdb -qO /var/mmdb/GeoLite2-Country.mmdb \
  # PHP geoip2 extension
  && wget -q https://pecl.php.net/get/geoip-${GEOIP_EXT_VERSION}.tgz \
  && pecl install geoip-${GEOIP_EXT_VERSION}.tgz \
  && rm -f geoip-${GEOIP_EXT_VERSION}.tgz \
  && apk del build-dependencies \
  && chown -R nobody.nogroup /var/www \
  && rm -rf /etc/nginx/conf.d/* \
    /usr/src/nginx* \
    /tmp/* \
    /var/cache/apk/* \
    /var/www/rutorrent/.git* \
    /var/www/rutorrent/conf/users \
    /var/www/rutorrent/plugins/geoip \
    /var/www/rutorrent/plugins/geoip2/.git \
    /var/www/rutorrent/share

ENV PYTHONPATH="$PYTHONPATH:/var/www/rutorrent" \
  S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

COPY rootfs /

RUN chmod a+x /usr/local/bin/* \
  && addgroup -g ${PGID} rtorrent \
  && adduser -D -H -u ${PUID} -G rtorrent -s /bin/sh rtorrent

EXPOSE 6881/udp 8000 8080 9000 50000
VOLUME [ "/data", "/downloads", "/passwd" ]

ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
  CMD /usr/local/bin/healthcheck
