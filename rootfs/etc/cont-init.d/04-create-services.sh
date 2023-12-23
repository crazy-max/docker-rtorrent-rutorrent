#!/usr/bin/with-contenv sh
# shellcheck shell=sh

mkdir -p /etc/services.d/nginx
cat > /etc/services.d/nginx/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
nginx -g "daemon off;"
EOL
chmod +x /etc/services.d/nginx/run

mkdir -p /etc/services.d/php-fpm
cat > /etc/services.d/php-fpm/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
php-fpm82 -F
EOL
chmod +x /etc/services.d/php-fpm/run

mkdir -p /etc/services.d/rtorrent
cat > /etc/services.d/rtorrent/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/bin/export HOME /data/rtorrent
/bin/export PWD /data/rtorrent
s6-setuidgid ${PUID}:${PGID}
EOL
if [ -z "${WAN_IP}" ]; then
  echo "rtorrent -D -o import=/etc/rtorrent/.rtlocal.rc" >> /etc/services.d/rtorrent/run
else
  echo "rtorrent -D -o import=/etc/rtorrent/.rtlocal.rc -i ${WAN_IP}" >> /etc/services.d/rtorrent/run
fi

chmod +x /etc/services.d/rtorrent/run
