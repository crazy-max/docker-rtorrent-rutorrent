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
  XMLRPC_VERSION=01.51.00 \
  LIBSIG_VERSION=2.10.0 \
  CARES_VERSION=1.14.0 \
  CURL_VERSION=7.60.0

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
  && cd /tmp \
  && svn checkout http://svn.code.sf.net/p/xmlrpc-c/code/release_number/${XMLRPC_VERSION}/ xmlrpc-c \
  && cd xmlrpc-c && ./configure && make && make install \
  && cd /tmp && wget http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.10/libsigc++-${LIBSIG_VERSION}.tar.xz \
  && unxz libsigc++-${LIBSIG_VERSION}.tar.xz && tar -xf libsigc++-${LIBSIG_VERSION}.tar \
  && cd libsigc++-${LIBSIG_VERSION} && ./configure && make && make install \
  && cd /tmp && wget https://c-ares.haxx.se/download/c-ares-${CARES_VERSION}.tar.gz \
  && tar zxf c-ares-${CARES_VERSION}.tar.gz \
  && cd c-ares-${CARES_VERSION} && ./configure && make && make install \
  && cd /tmp && wget https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz \
  && tar zxf curl-${CURL_VERSION}.tar.gz \
  && cd curl-${CURL_VERSION} && ./configure --enable-ares --enable-tls-srp --enable-gnu-tls --with-ssl --with-zlib && make && make install \
  && cd /tmp && git clone https://github.com/rakshasa/libtorrent.git && cd libtorrent && git checkout tags/v${LIBTORRENT_VERSION} \
  && ./autogen.sh && ./configure --with-posix-fallocate && make && make install \
  && cd /tmp && git clone https://github.com/rakshasa/rtorrent.git && cd rtorrent && git checkout tags/v${RTORRENT_VERSION} \
  && ./autogen.sh && ./configure --with-xmlrpc-c --with-ncurses && make && make install \
  && apk del build-dependencies \
  && rm -rf /tmp/* /var/cache/apk/*

ENV RUTORRENT_VERSION="3.8" \
  RUTORRENT_REVISION="44d43229f07212f20b53b6301fb25882125876c3"

RUN apk --update --no-cache add \
    apache2-utils \
    bind-tools \
    binutils \
    ca-certificates \
    coreutils \
    curl \
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
    expat-dev \
    git \
    linux-headers \
    libressl-dev \
    pcre-dev \
    zlib-dev \
  && cd /usr/src \
  && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
  && tar zxvf nginx-$NGINX_VERSION.tar.gz \
  && git clone -b master --single-branch https://github.com/arut/nginx-dav-ext-module.git \
  && cd nginx-$NGINX_VERSION \
  && ./configure --with-compat --add-dynamic-module=../nginx-dav-ext-module \
  && make modules \
  && cp objs/ngx_http_dav_ext_module.so /etc/nginx/modules \
  && mkdir -p /data /var/log/supervisord /var/www \
  && cd /var/www \
  && git clone https://github.com/Novik/ruTorrent.git rutorrent \
  && cd rutorrent \
  && git checkout ${RUTORRENT_REVISION} \
  && addgroup -g 1000 rtorrent \
  && adduser -u 1000 -G rtorrent -h /home/rtorrent -s /sbin/nologin -D rtorrent \
  && usermod -a -G rtorrent nginx \
  && chown -R rtorrent. /data /var/log/php7 /var/www/rutorrent \
  && apk del build-dependencies \
  && rm -rf /usr/src/nginx* \
    /tmp/* \
    /var/cache/apk/* \
    /var/www/rutorrent/.git* \
    /var/www/rutorrent/conf/users \
    /var/www/rutorrent/share

COPY entrypoint.sh /entrypoint.sh
COPY assets /

RUN chmod a+x /entrypoint.sh \
  && chown -R nginx. /etc/nginx/conf.d /var/log/nginx

EXPOSE 80 6881/udp 8000 9000 50000
VOLUME [ "/data", "/passwd" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
