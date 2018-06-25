FROM alpine:3.7
MAINTAINER CrazyMax <crazy-max@users.noreply.github.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="rtorrent-rutorrent" \
  org.label-schema.description="rTorrent and ruTorrent Docker image based on Alpine Linux" \
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
    build-base \
    git \
    libtool \
    linux-headers \
    automake \
    autoconf \
    subversion \
    tar \
    wget \
    xz \
    binutils \
    cppunit-dev \
    libressl-dev \
    ncurses-dev \
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
  && cd curl-${CURL_VERSION}  && ./configure --enable-ares --enable-tls-srp --enable-gnu-tls --with-ssl --with-zlib && make && make install \
  && cd /tmp && git clone https://github.com/rakshasa/libtorrent.git && cd libtorrent && git checkout tags/v${LIBTORRENT_VERSION} \
  && ./autogen.sh && ./configure --with-posix-fallocate && make && make install \
  && cd /tmp && git clone https://github.com/rakshasa/rtorrent.git && cd rtorrent && git checkout tags/v${RTORRENT_VERSION} \
  && ./autogen.sh && ./configure --with-xmlrpc-c --with-ncurses && make && make install \
  && cd /tmp && rm -rf * \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/*

ENV NGINX_VERSION=1.14.0

RUN apk add --no-cache \
    ca-certificates \
    libressl \
    pcre \
    zlib \
  && apk --update --no-cache add -t build-dependencies \
    build-base \
    expat-dev \
    git \
    linux-headers \
    libressl-dev \
    pcre-dev \
    wget \
    zlib-dev \
  && cd /tmp \
  && git clone https://github.com/arut/nginx-dav-ext-module.git \
  && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar xzf nginx-${NGINX_VERSION}.tar.gz \
  && cd /tmp/nginx-${NGINX_VERSION} \
  && ./configure \
    \
    --prefix=/var/lib/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/run/nginx/nginx.pid \
    --lock-path=/run/nginx/nginx.lock \
    \
    --user=nginx \
    --group=nginx \
    \
    --with-threads \
    --with-file-aio \
    \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    \
    --http-client-body-temp-path=/var/tmp/nginx/client_body \
    --http-proxy-temp-path=/var/tmp/nginx/proxy \
    --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
    --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
    --http-scgi-temp-path=/var/tmp/nginx/scgi \
    \
    --with-mail \
    --with-mail_ssl_module \
    \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    \
    --add-module=/tmp/nginx-dav-ext-module \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && addgroup -g 102 nginx \
  && adduser -u 101 -G nginx -h /var/lib/nginx -s /sbin/nologin -D nginx \
  && mkdir -p /etc/nginx/conf.d /run/nginx /var/lib/nginx /var/log/nginx /var/tmp/nginx \
  && chown -R nginx. /etc/nginx/conf.d /run/nginx /var/lib/nginx /var/log/nginx /var/tmp/nginx \
  && rm -rf /tmp/* \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/*

RUN apk --update --no-cache add \
    binutils coreutils grep shadow supervisor tzdata util-linux zlib \
    apache2-utils ca-certificates bind-tools dhclient libressl libstdc++ ncurses \
    curl ffmpeg geoip gzip mediainfo sox tar unrar unzip wget zip \
    php7 php7-cli php7-ctype php7-curl php7-fpm php7-json php7-mbstring php7-openssl php7-session php7-sockets \
    php7-xml php7-zip php7-zlib \
  && mkdir -p /var/log/supervisord \
  && rm -rf /var/cache/apk/*

ENV RUTORRENT_VERSION="3.8" \
  RUTORRENT_REVISION="44d43229f07212f20b53b6301fb25882125876c3"

RUN apk --update --no-cache add -t build-dependencies \
    git \
  && mkdir /var/www \
  && cd /var/www \
  && git clone https://github.com/Novik/ruTorrent.git rutorrent \
  && cd rutorrent \
  && git checkout ${RUTORRENT_REVISION} \
  && rm -rf .git* conf/users share \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
ADD assets /

RUN mkdir -p /data /var/log/supervisord \
  && chmod a+x /entrypoint.sh \
  && addgroup -g 1000 rtorrent \
  && adduser -u 1000 -G rtorrent -h /home/rtorrent -s /sbin/nologin -D rtorrent \
  && usermod -a -G rtorrent nginx \
  && chown -R nginx. /etc/nginx/conf.d /run/nginx /var/lib/nginx /var/log/nginx /var/tmp/nginx \
  && chown -R rtorrent. /data /var/log/php7 /var/www/rutorrent

EXPOSE 80 6881/udp 8000 9000 50000
VOLUME [ "/data", "/passwd" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
