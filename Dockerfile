FROM alpine:3.6
MAINTAINER CrazyMax <crazy-max@users.noreply.github.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="rtorrent" \
  org.label-schema.description="rTorrent Docker image based on Alpine" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-rtorrent" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-rtorrent" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ARG RTORRENT_VERSION=0.9.6
ARG LIBTORRENT_VERSION=0.13.6
ARG XMLRPC_VERSION=01.51.00
ARG LIBSIG_VERSION=2.10.0
ARG CARES_VERSION=1.13.0
ARG CURL_VERSION=7.55.1

RUN apk --update --no-cache add -t build-dependencies \
    build-base \
    git \
    libtool \
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
  && cd /tmp && git clone https://github.com/rakshasa/libtorrent.git && cd libtorrent && git checkout tags/${LIBTORRENT_VERSION} \
  && ./autogen.sh && ./configure --with-posix-fallocate && make && make install \
  && cd /tmp && git clone https://github.com/rakshasa/rtorrent.git && cd rtorrent && git checkout tags/${RTORRENT_VERSION} \
  && ./autogen.sh && ./configure --with-xmlrpc-c --with-ncurses && make && make install \
  && cd /tmp && rm -rf * \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/*

RUN apk --update --no-cache add \
    ca-certificates \
    bind-tools \
    dhclient \
    libressl \
    libstdc++ \
    ncurses \
    shadow \
    supervisor \
    tzdata \
    zlib \
  && rm -rf /var/cache/apk/*

ENV HOME_PATH="/home/rtorrent" \
  UID=1000 \
  GID=1000

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
  && addgroup -g ${GID} rtorrent \
  && adduser -u ${UID} -G rtorrent -h ${HOME_PATH} -s /bin/sh -D rtorrent

ADD assets /

EXPOSE 5000 6881/udp 50000 50000/udp
VOLUME [ "${HOME_PATH}" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord" ]
