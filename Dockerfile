FROM nginx:stable-alpine

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

ENV RTORRENT_VERSION=0.9.7 \
  LIBTORRENT_VERSION=0.13.7 \
  XMLRPC_VERSION=01.54.00 \
  LIBSIG_VERSION=2.10.1 \
  CARES_VERSION=1.14.0 \
  CURL_VERSION=7.63.0 \
  MKTORRENT_VERSION=1.1 \
  NGINX_DAV_VERSION=3.0.0

RUN apk --update --no-cache add -t build-dependencies \
    autoconf \
    automake \
    binutils \
    build-base \
    cppunit-dev \
    git \
    libtool \
    libressl-dev \
    linux-headers \
    ncurses-dev \
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
  && wget http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.10/libsigc++-${LIBSIG_VERSION}.tar.xz \
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
  && ./configure --enable-ares --enable-tls-srp --enable-gnu-tls --with-ssl --with-zlib \
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

ENV RUTORRENT_VERSION="3.9" \
  RUTORRENT_REVISION="702afd3"

RUN apk --update --no-cache add \
    apache2-utils \
    bind-tools \
    binutils \
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
    git \
    linux-headers \
    libressl-dev \
    pcre-dev \
    zlib-dev \
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
  && mkdir -p /data /var/log/supervisord /var/www \
  && cd /var/www \
  && git clone https://github.com/Novik/ruTorrent.git rutorrent \
  && cd rutorrent \
  && git checkout ${RUTORRENT_REVISION} \
  # geoip2
  && git clone https://github.com/Micdu70/geoip2-rutorrent /var/www/rutorrent/plugins/geoip2 \
  && cd /var/www/rutorrent/plugins/geoip2/database \
  && wget -q http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
  && wget -q http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar -xvzf GeoLite2-City.tar.gz --strip-components=1 \
  && tar -xvzf GeoLite2-Country.tar.gz --strip-components=1 \
  && rm -f *.gz \
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

COPY entrypoint.sh /entrypoint.sh
COPY assets /

RUN chmod a+x /entrypoint.sh \
  && chown -R nginx. /etc/nginx/conf.d /var/log/nginx

EXPOSE 6881/udp 8000 8080 9000 50000
VOLUME [ "/data", "/passwd" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
