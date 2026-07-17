#!/usr/bin/with-contenv sh
# shellcheck shell=sh

DATA_DIR=${DATA_DIR%/:-/data}
DOWNLOAD_DIR=${DOWNLOAD_DIR%/:-/downloads}

echo "Fixing perms..."
mkdir -p "${DATA_DIR}/rtorrent" \
  "${DATA_DIR}/rutorrent" \
  "${DOWNLOAD_DIR}" \
  /passwd \
  /etc/nginx/conf.d \
  /etc/rtorrent \
  /var/cache/nginx \
  /var/lib/nginx \
  /var/log/nginx \
  /var/run/nginx \
  /var/run/php-fpm \
  /var/run/rtorrent
chown rtorrent:rtorrent \
  "${DATA_DIR}" \
  "${DATA_DIR}/rtorrent" \
  "${DATA_DIR}/rutorrent" \
  "${DOWNLOAD_DIR}"
chown -R rtorrent:rtorrent \
  /etc/rtorrent \
  /passwd \
  /tpls \
  /var/cache/nginx \
  /var/lib/nginx \
  /var/log/nginx \
  /var/log/php84 \
  /var/run/nginx \
  /var/run/php-fpm \
  /var/run/rtorrent
