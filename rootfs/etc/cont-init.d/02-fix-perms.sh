#!/usr/bin/with-contenv sh

echo "Fixing perms..."
chown rtorrent. \
  /data
chown -R rtorrent. \
  /etc/rtorrent \
  /passwd \
  /tpls \
  /var/cache/nginx \
  /var/lib/nginx \
  /var/log/nginx \
  /var/log/php7 \
  /var/run/nginx \
  /var/run/php-fpm \
  /var/run/rtorrent
