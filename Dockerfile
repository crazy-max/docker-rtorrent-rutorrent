FROM nginx:mainline-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="rtorrent-rutorrent" \
  org.label-schema.description="rTorrent and ruTorrent" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-rtorrent-rutorrent" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-rtorrent-rutorrent" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ENV RTORRENT_VERSION=0.9.8 \
    LIBTORRENT_VERSION=0.13.8 \
    XMLRPC_VERSION=advanced \
    LIBSIG_VERSION=3.0.0 \
    CURL_VERSION=7.66.0 \
    MKTORRENT_VERSION=1.1 \
    NGINX_DAV_VERSION=3.0.0 \
    RUTORRENT_VERSION=3.10-beta \
    GEOIP_EXT_VERSION=1.1.1

RUN apk --update --no-cache add -t build-dependencies \
    autoconf \
    automake \
    binutils \
    build-base \
    c-ares-dev \
    cppunit-dev \
    git \
    libtool \
    libressl-dev \
    linux-headers \
    ncurses-dev \
    nghttp2-dev \
    tar \
    wget \
    xz \
    zlib-dev \
  # xmlrpc
  && cd /tmp \
  && git clone -q --depth 1 https://github.com/mirror/xmlrpc-c.git \
  && cd xmlrpc-c/${XMLRPC_VERSION} \
  && ./configure \
  && make \
  && make install \
  # libsig
  && cd /tmp \
  && wget -q https://ftp.gnome.org/pub/GNOME/sources/libsigc++/3.0/libsigc++-${LIBSIG_VERSION}.tar.xz \
  && tar xJf libsigc++-${LIBSIG_VERSION}.tar.xz \
  && cd libsigc++-${LIBSIG_VERSION} \
  && ./configure \
  && make \
  && make install \
  # curl
  && cd /tmp \
  && wget -q https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz \
  && tar xzf curl-${CURL_VERSION}.tar.gz \
  && cd curl-${CURL_VERSION} \
  && ./configure --enable-ares --enable-tls-srp --enable-gnu-tls --with-ssl --with-zlib --with-nghttp2 \
  && make \
  && make install \
  # libtorrent
  && cd /tmp \
  && git clone -b v${LIBTORRENT_VERSION} -q --depth 1 https://github.com/rakshasa/libtorrent.git \
  && cd libtorrent \
  && ./autogen.sh \
  && ./configure --with-posix-fallocate \
  && make \
  && make install \
  # rtorrent
  && cd /tmp \
  && git clone -b v${RTORRENT_VERSION} -q --depth 1 https://github.com/rakshasa/rtorrent.git \
  && cd rtorrent \
  && ./autogen.sh \
  && ./configure --with-xmlrpc-c --with-ncurses \
  && make \
  && make install \
  # mktorrent
  && git clone -b v${MKTORRENT_VERSION} -q --depth 1 https://github.com/esmil/mktorrent.git \
  && cd mktorrent \
  && make \
  && make install \
  && apk del build-dependencies \
  && rm -rf /tmp/* /var/cache/apk/*

RUN apk --update --no-cache add \
    apache2-utils \
    bind-tools \
    binutils \
    c-ares \
    ca-certificates \
    coreutils \
    dhclient \
    ffmpeg \
    geoip \
    grep \
    gzip \
    libressl \
    libstdc++ \
    mediainfo \
    ncurses \
    pcre \
    php7 \
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
    python2 \
    shadow \
    sox \
    supervisor \
    tar \
    tzdata \
    unrar \
    unzip \
    util-linux \
    wget \
    zip \
    zlib \
  && apk --update --no-cache add -t build-dependencies \
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
    py2-pip \
    python2-dev \
    zlib-dev \
  # nginx webdav
  && mkdir -p /usr/src \
  && cd /usr/src \
  && wget -q https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
  && tar xzf nginx-$NGINX_VERSION.tar.gz \
  && git clone -b v${NGINX_DAV_VERSION} -q --depth 1 https://github.com/arut/nginx-dav-ext-module.git \
  && cd nginx-$NGINX_VERSION \
  && ./configure --with-compat --add-dynamic-module=../nginx-dav-ext-module \
  && make modules \
  && cp objs/ngx_http_dav_ext_module.so /etc/nginx/modules \
  # ruTorrent
  && mkdir -p /data /var/log/supervisord /var/www \
  && cd /var/www \
  && git clone -b v${RUTORRENT_VERSION} -q --depth 1 https://github.com/Novik/ruTorrent.git rutorrent \
  && cd rutorrent \
  && pip2 install cfscrape cloudscraper \
  # geoip2
  && git clone -q --depth 1 https://github.com/Micdu70/geoip2-rutorrent /var/www/rutorrent/plugins/geoip2 \
  && cd /var/www/rutorrent/plugins/geoip2/database \
  && wget -q https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
  && wget -q https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar xzf GeoLite2-City.tar.gz --strip-components=1 \
  && tar xzf GeoLite2-Country.tar.gz --strip-components=1 \
  && rm -f *.gz \
  && wget -q https://pecl.php.net/get/geoip-${GEOIP_EXT_VERSION}.tgz \
  && pecl install geoip-${GEOIP_EXT_VERSION}.tgz \
  && rm -f geoip-${GEOIP_EXT_VERSION}.tgz \
  # perms
  && addgroup -g 1000 rtorrent \
  && adduser -u 1000 -G rtorrent -h /home/rtorrent -s /sbin/nologin -D rtorrent \
  && usermod -a -G rtorrent nginx \
  && chown -R rtorrent. /data /var/log/php7 /var/www/rutorrent \
  && apk del build-dependencies \
  && rm -rf /etc/nginx/conf.d/* \
    /usr/src/nginx* \
    /tmp/* \
    /var/cache/apk/* \
    /var/www/rutorrent/.git* \
    /var/www/rutorrent/conf/users \
    /var/www/rutorrent/plugins/geoip \
    /var/www/rutorrent/plugins/geoip2/.git \
    /var/www/rutorrent/share

ENV PYTHONPATH="$PYTHONPATH:/var/www/rutorrent"

COPY entrypoint.sh /entrypoint.sh
COPY assets /

RUN chmod a+x /entrypoint.sh /usr/local/bin/* \
  && chown -R nginx. /etc/nginx/conf.d /var/log/nginx

EXPOSE 6881/udp 8000 8080 9000 50000
VOLUME [ "/data", "/passwd" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD /usr/local/bin/healthcheck
