FROM alpine:3.7
MAINTAINER CrazyMax <crazy-max@users.noreply.github.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="rtorrent" \
  org.label-schema.description="rTorrent Docker image based on Alpine Linux" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-rtorrent" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-rtorrent" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ARG RTORRENT_VERSION=0.9.7
ARG LIBTORRENT_VERSION=0.13.7
ARG XMLRPC_VERSION=01.51.00
ARG LIBSIG_VERSION=2.10.0
ARG CARES_VERSION=1.14.0
ARG CURL_VERSION=7.60.0

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

RUN apk --update --no-cache add \
    apache2 \
    apache2-webdav \
    apache2-utils \
    ca-certificates \
    bind-tools \
    dhclient \
    libressl \
    libstdc++ \
    ncurses \
    nginx \
    shadow \
    supervisor \
    tzdata \
    zlib \
  && mkdir -p /var/log/supervisord \
  && rm -rf /var/cache/apk/*

ENV RTORRENT_HOME="/var/rtorrent" \
  PUID=1000 \
  PGID=1000

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
  && addgroup -g ${PGID} rtorrent \
  && adduser -u ${PUID} -G rtorrent -h /home/rtorrent -s /bin/sh -D rtorrent \
  && usermod -a -G rtorrent apache \
  && sed -i "s/^Listen 80/#Listen 80/g" /etc/apache2/httpd.conf \
  && mkdir -p /etc/apache2/dav /run/apache2 \
  && chown apache. /etc/apache2/dav \
  && usermod -a -G rtorrent nginx \
  && chown -R nginx. /var/lib/nginx /var/log/nginx /var/tmp/nginx

ADD assets /

EXPOSE 6881/udp 8000 9000 50000
VOLUME [ "${RTORRENT_HOME}" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
