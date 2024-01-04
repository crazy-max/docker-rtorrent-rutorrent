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
EOL

[[ -z "${WAN_IP}" ]] && wan="" || wan="-i ${WAN_IP}"
if [ "${RT_DAEMON_MODE}" = false ]; then
  echo "screen -D -m -S rtorrent s6-setuidgid ${PUID}:${PGID} rtorrent -D -o system.daemon.set=${RT_DAEMON_MODE} -o import=/etc/rtorrent/.rtlocal.rc ${wan}" >> /etc/services.d/rtorrent/run
else
  echo "s6-setuidgid ${PUID}:${PGID}" >> /etc/services.d/rtorrent/run
  echo "rtorrent -D -o system.daemon.set=${RT_DAEMON_MODE} -o import=/etc/rtorrent/.rtlocal.rc ${wan}" >> /etc/services.d/rtorrent/run
fi

chmod +x /etc/services.d/rtorrent/run
