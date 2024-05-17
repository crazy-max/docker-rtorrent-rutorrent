#!/usr/bin/with-contenv sh
# shellcheck shell=sh

#WAN_IP=${WAN_IP:-10.0.0.1}
#WAN_IP_CMD=${WAN_IP_CMD:-"dig +short myip.opendns.com @resolver1.opendns.com"}

TZ=${TZ:-UTC}
MEMORY_LIMIT=${MEMORY_LIMIT:-256M}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-16M}
CLEAR_ENV=${CLEAR_ENV:-yes}
OPCACHE_MEM_SIZE=${OPCACHE_MEM_SIZE:-128}
MAX_FILE_UPLOADS=${MAX_FILE_UPLOADS:-50}
AUTH_DELAY=${AUTH_DELAY:-0s}
REAL_IP_FROM=${REAL_IP_FROM:-0.0.0.0/32}
REAL_IP_HEADER=${REAL_IP_HEADER:-X-Forwarded-For}
LOG_IP_VAR=${LOG_IP_VAR:-remote_addr}
LOG_ACCESS=${LOG_ACCESS:-true}
XMLRPC_SIZE_LIMIT=${XMLRPC_SIZE_LIMIT:-1M}

XMLRPC_AUTHBASIC_STRING=${XMLRPC_AUTHBASIC_STRING:-rTorrent XMLRPC restricted access}
RUTORRENT_AUTHBASIC_STRING=${RUTORRENT_AUTHBASIC_STRING:-ruTorrent restricted access}
WEBDAV_AUTHBASIC_STRING=${WEBDAV_AUTHBASIC_STRING:-WebDAV restricted access}

RT_LOG_LEVEL=${RT_LOG_LEVEL:-info}
RT_LOG_EXECUTE=${RT_LOG_EXECUTE:-false}
RT_LOG_XMLRPC=${RT_LOG_XMLRPC:-false}
RT_SESSION_SAVE_SECONDS=${RT_SESSION_SAVE_SECONDS:-3600}
RT_TRACKER_DELAY_SCRAPE=${RT_TRACKER_DELAY_SCRAPE:-true}
RT_SEND_BUFFER_SIZE=${RT_SEND_BUFFER_SIZE:-4M}
RT_RECEIVE_BUFFER_SIZE=${RT_RECEIVE_BUFFER_SIZE:-4M}

RU_REMOVE_CORE_PLUGINS=${RU_REMOVE_CORE_PLUGINS:-false}
RU_HTTP_USER_AGENT=${RU_HTTP_USER_AGENT:-Mozilla/5.0 (Windows NT 6.0; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0}
RU_HTTP_TIME_OUT=${RU_HTTP_TIME_OUT:-30}
RU_HTTP_USE_GZIP=${RU_HTTP_USE_GZIP:-true}
RU_RPC_TIME_OUT=${RU_RPC_TIME_OUT:-5}
RU_LOG_RPC_CALLS=${RU_LOG_RPC_CALLS:-false}
RU_LOG_RPC_FAULTS=${RU_LOG_RPC_FAULTS:-true}
RU_PHP_USE_GZIP=${RU_PHP_USE_GZIP:-false}
RU_PHP_GZIP_LEVEL=${RU_PHP_GZIP_LEVEL:-2}
RU_SCHEDULE_RAND=${RU_SCHEDULE_RAND:-10}
RU_LOG_FILE=${RU_LOG_FILE:-/data/rutorrent/rutorrent.log}
RU_DO_DIAGNOSTIC=${RU_DO_DIAGNOSTIC:-true}
RU_CACHED_PLUGIN_LOADING=${RU_CACHED_PLUGIN_LOADING:-false}
RU_SAVE_UPLOADED_TORRENTS=${RU_SAVE_UPLOADED_TORRENTS:-true}
RU_OVERWRITE_UPLOADED_TORRENTS=${RU_OVERWRITE_UPLOADED_TORRENTS:-false}
RU_FORBID_USER_SETTINGS=${RU_FORBID_USER_SETTINGS:-false}
RU_LOCALE=${RU_LOCALE:-UTF8}

RT_DHT_PORT=${RT_DHT_PORT:-6881}
RT_INC_PORT=${RT_INC_PORT:-50000}
XMLRPC_PORT=${XMLRPC_PORT:-8000}
XMLRPC_HEALTH_PORT=$((XMLRPC_PORT + 1))
RUTORRENT_PORT=${RUTORRENT_PORT:-8080}
RUTORRENT_HEALTH_PORT=$((RUTORRENT_PORT + 1))
WEBDAV_PORT=${WEBDAV_PORT:-9000}
WEBDAV_HEALTH_PORT=$((WEBDAV_PORT + 1))

# WAN IP
if [ -z "$WAN_IP" ] && [ -n "$WAN_IP_CMD" ]; then
  WAN_IP=$(eval "$WAN_IP_CMD")
fi
if [ -n "$WAN_IP" ]; then
  echo "Public IP address enforced to ${WAN_IP}"
fi
printf "%s" "$WAN_IP" > /var/run/s6/container_environment/WAN_IP

# Timezone
echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# PHP
echo "Setting PHP-FPM configuration..."
sed -e "s/@MEMORY_LIMIT@/$MEMORY_LIMIT/g" \
  -e "s/@UPLOAD_MAX_SIZE@/$UPLOAD_MAX_SIZE/g" \
  -e "s/@CLEAR_ENV@/$CLEAR_ENV/g" \
  /tpls/etc/php82/php-fpm.d/www.conf > /etc/php82/php-fpm.d/www.conf

echo "Setting PHP INI configuration..."
sed -i "s|memory_limit.*|memory_limit = ${MEMORY_LIMIT}|g" /etc/php82/php.ini
sed -i "s|;date\.timezone.*|date\.timezone = ${TZ}|g" /etc/php82/php.ini
sed -i "s|max_file_uploads.*|max_file_uploads = ${MAX_FILE_UPLOADS}|g" /etc/php82/php.ini

# OpCache
echo "Setting OpCache configuration..."
sed -e "s/@OPCACHE_MEM_SIZE@/$OPCACHE_MEM_SIZE/g" \
  /tpls/etc/php82/conf.d/opcache.ini > /etc/php82/conf.d/opcache.ini

# Nginx
echo "Setting Nginx configuration..."
sed -e "s#@REAL_IP_FROM@#$REAL_IP_FROM#g" \
  -e "s#@REAL_IP_HEADER@#$REAL_IP_HEADER#g" \
  -e "s#@LOG_IP_VAR@#$LOG_IP_VAR#g" \
  -e "s#@AUTH_DELAY@#$AUTH_DELAY#g" \
  /tpls/etc/nginx/nginx.conf > /etc/nginx/nginx.conf
if [ "${LOG_ACCESS}" != "true" ]; then
  echo "  Disabling Nginx access log..."
  sed -i "s!access_log /proc/self/fd/1 main!access_log off!g" /etc/nginx/nginx.conf
fi

# Nginx XMLRPC over SCGI
echo "Setting Nginx XMLRPC over SCGI configuration..."
sed -e "s!@XMLRPC_AUTHBASIC_STRING@!$XMLRPC_AUTHBASIC_STRING!g" \
  -e "s!@XMLRPC_PORT@!$XMLRPC_PORT!g" \
  -e "s!@XMLRPC_HEALTH_PORT@!$XMLRPC_HEALTH_PORT!g" \
  -e "s!@XMLRPC_SIZE_LIMIT@!$XMLRPC_SIZE_LIMIT!g" \
  /tpls/etc/nginx/conf.d/rpc.conf > /etc/nginx/conf.d/rpc.conf

# Nginx ruTorrent
echo "Setting Nginx ruTorrent configuration..."
sed -e "s!@UPLOAD_MAX_SIZE@!$UPLOAD_MAX_SIZE!g" \
  -e "s!@RUTORRENT_AUTHBASIC_STRING@!$RUTORRENT_AUTHBASIC_STRING!g" \
  -e "s!@RUTORRENT_PORT@!$RUTORRENT_PORT!g" \
  -e "s!@RUTORRENT_HEALTH_PORT@!$RUTORRENT_HEALTH_PORT!g" \
  /tpls/etc/nginx/conf.d/rutorrent.conf > /etc/nginx/conf.d/rutorrent.conf

# Nginx WebDAV
echo "Setting Nginx WebDAV configuration..."
sed -e "s!@WEBDAV_AUTHBASIC_STRING@!$WEBDAV_AUTHBASIC_STRING!g" \
  -e "s!@WEBDAV_PORT@!$WEBDAV_PORT!g" \
  -e "s!@WEBDAV_HEALTH_PORT@!$WEBDAV_HEALTH_PORT!g" \
  /tpls/etc/nginx/conf.d/webdav.conf > /etc/nginx/conf.d/webdav.conf

# Healthcheck
echo "Update healthcheck script..."
cat > /usr/local/bin/healthcheck <<EOL
#!/bin/sh
set -e

# rTorrent
curl --fail -d "<?xml version='1.0'?><methodCall><methodName>system.api_version</methodName></methodCall>" http://127.0.0.1:${XMLRPC_HEALTH_PORT}

# ruTorrent / PHP
curl --fail http://127.0.0.1:${RUTORRENT_HEALTH_PORT}/ping

# WebDAV
curl --fail http://127.0.0.1:${WEBDAV_HEALTH_PORT}
EOL

# Init
echo "Initializing files and folders..."
mkdir -p /data/geoip \
  /data/rtorrent/log \
  /data/rtorrent/.session \
  /data/rtorrent/watch \
  /data/rutorrent/conf/users \
  /data/rutorrent/plugins \
  /data/rutorrent/plugins-conf \
  /data/rutorrent/share/users \
  /data/rutorrent/share/torrents \
  /data/rutorrent/themes \
  /downloads/complete \
  /downloads/temp
touch /passwd/rpc.htpasswd \
  /passwd/rutorrent.htpasswd \
  /passwd/webdav.htpasswd \
  /data/rtorrent/log/rtorrent.log \
  "${RU_LOG_FILE}"
rm -f /data/rtorrent/.session/rtorrent.lock

# Check htpasswd files
if [ ! -s "/passwd/rpc.htpasswd" ]; then
  echo "rpc.htpasswd is empty, removing authentication..."
  sed -i "s!auth_basic .*!#auth_basic!g" /etc/nginx/conf.d/rpc.conf
  sed -i "s!auth_basic_user_file.*!#auth_basic_user_file!g" /etc/nginx/conf.d/rpc.conf
fi
if [ ! -s "/passwd/rutorrent.htpasswd" ]; then
  echo "rutorrent.htpasswd is empty, removing authentication..."
  sed -i "s!auth_basic .*!#auth_basic!g" /etc/nginx/conf.d/rutorrent.conf
  sed -i "s!auth_basic_user_file.*!#auth_basic_user_file!g" /etc/nginx/conf.d/rutorrent.conf
fi
if [ ! -s "/passwd/webdav.htpasswd" ]; then
  echo "webdav.htpasswd is empty, removing authentication..."
  sed -i "s!auth_basic .*!#auth_basic!g" /etc/nginx/conf.d/webdav.conf
  sed -i "s!auth_basic_user_file.*!#auth_basic_user_file!g" /etc/nginx/conf.d/webdav.conf
fi

# rTorrent local config
echo "Checking rTorrent local configuration..."
sed -e "s!@RT_LOG_LEVEL@!$RT_LOG_LEVEL!g" \
  -e "s!@RT_DHT_PORT@!$RT_DHT_PORT!g" \
  -e "s!@RT_INC_PORT@!$RT_INC_PORT!g" \
  -e "s!@XMLRPC_SIZE_LIMIT@!$XMLRPC_SIZE_LIMIT!g" \
  -e "s!@RT_SESSION_SAVE_SECONDS@!$RT_SESSION_SAVE_SECONDS!g" \
  -e "s!@RT_TRACKER_DELAY_SCRAPE@!$RT_TRACKER_DELAY_SCRAPE!g" \
  -e "s!@RT_SEND_BUFFER_SIZE@!$RT_SEND_BUFFER_SIZE!g" \
  -e "s!@RT_RECEIVE_BUFFER_SIZE@!$RT_RECEIVE_BUFFER_SIZE!g" \
  /tpls/etc/rtorrent/.rtlocal.rc > /etc/rtorrent/.rtlocal.rc
if [ "${RT_LOG_EXECUTE}" = "true" ]; then
  echo "  Enabling rTorrent execute log..."
  sed -i "s!#log\.execute.*!log\.execute = (cat,(cfg.logs),\"execute.log\")!g" /etc/rtorrent/.rtlocal.rc
fi
if [ "${RT_LOG_XMLRPC}" = "true" ]; then
  echo "  Enabling rTorrent xmlrpc log..."
  sed -i "s!#log\.xmlrpc.*!log\.xmlrpc = (cat,(cfg.logs),\"xmlrpc.log\")!g" /etc/rtorrent/.rtlocal.rc
fi

# rTorrent config
echo "Checking rTorrent configuration..."
if [ ! -f /data/rtorrent/.rtorrent.rc ]; then
  echo "  Creating default configuration..."
  cp /tpls/.rtorrent.rc /data/rtorrent/.rtorrent.rc
fi
chown rtorrent:rtorrent /data/rtorrent/.rtorrent.rc

# ruTorrent config
echo "Bootstrapping ruTorrent configuration..."
cat > /var/www/rutorrent/conf/config.php <<EOL
<?php

// for snoopy client
\$httpUserAgent = '${RU_HTTP_USER_AGENT}';
\$httpTimeOut = ${RU_HTTP_TIME_OUT};
\$httpUseGzip = ${RU_HTTP_USE_GZIP};

// for xmlrpc actions
\$rpcTimeOut = ${RU_RPC_TIME_OUT};
\$rpcLogCalls = ${RU_LOG_RPC_CALLS};
\$rpcLogFaults = ${RU_LOG_RPC_FAULTS};

// for php
\$phpUseGzip = ${RU_PHP_USE_GZIP};
\$phpGzipLevel = ${RU_PHP_GZIP_LEVEL};

// Rand for schedulers start, +0..X seconds
\$schedule_rand = ${RU_SCHEDULE_RAND};

// Path to log file (comment or leave blank to disable logging)
\$log_file = '${RU_LOG_FILE}';
\$do_diagnostic = ${RU_DO_DIAGNOSTIC};

// Set to true if rTorrent is hosted on the SAME machine as ruTorrent
\$localHostedMode = true;

// Set to true to enable rapid cached loading of ruTorrent plugins
// Required to clear web browser cache during version upgrades
\$cachedPluginLoading = ${RU_CACHED_PLUGIN_LOADING};

// Save uploaded torrents to profile/torrents directory or not
\$saveUploadedTorrents = ${RU_SAVE_UPLOADED_TORRENTS};

// Overwrite existing uploaded torrents in profile/torrents directory or make unique name
\$overwriteUploadedTorrents = ${RU_OVERWRITE_UPLOADED_TORRENTS};

// Upper available directory. Absolute path with trail slash.
\$topDirectory = '/';
\$forbidUserSettings = ${RU_FORBID_USER_SETTINGS};

// For web->rtorrent link through unix domain socket
\$scgi_port = 0;
\$scgi_host = "unix:///var/run/rtorrent/scgi.socket";
\$XMLRPCMountPoint = "/RPC2"; // DO NOT DELETE THIS LINE!!! DO NOT COMMENT THIS LINE!!!
\$throttleMaxSpeed = 327625*1024; // DO NOT EDIT THIS LINE!!! DO NOT COMMENT THIS LINE!!!

\$pathToExternals = array(
    "php"    => '',
    "curl"   => '',
    "gzip"   => '',
    "id"     => '',
    "stat"   => '',
    "python" => '$(which python3)',
);

// List of local interfaces
\$localhosts = array(
    "127.0.0.1",
    "localhost",
);

// Path to user profiles
\$profilePath = '/data/rutorrent/share';
// Mask for files and directory creation in user profiles.
\$profileMask = 0770;

// Temp directory. Absolute path with trail slash. If null, then autodetect will be used.
\$tempDirectory = null;

// If true then use X-Sendfile feature if it exist
\$canUseXSendFile = false;

\$locale = '${RU_LOCALE}';

\$enableCSRFCheck = false; // If true then Origin and Referer will be checked
\$enabledOrigins = array(); // List of enabled domains for CSRF check (only hostnames, without protocols, port etc.). If empty, then will retrieve domain from HTTP_HOST / HTTP_X_FORWARDED_HOST
EOL
chown nobody:nogroup "/var/www/rutorrent/conf/config.php"

# Symlinking ruTorrent config
ln -sf /data/rutorrent/conf/users /var/www/rutorrent/conf/users
if [ ! -f /data/rutorrent/conf/access.ini ]; then
  echo "Symlinking ruTorrent access.ini file..."
  mv /var/www/rutorrent/conf/access.ini /data/rutorrent/conf/access.ini
  ln -sf /data/rutorrent/conf/access.ini /var/www/rutorrent/conf/access.ini
fi
chown rtorrent:rtorrent /data/rutorrent/conf/access.ini
if [ ! -f /data/rutorrent/conf/plugins.ini ]; then
  echo "Symlinking ruTorrent plugins.ini file..."
  mv /var/www/rutorrent/conf/plugins.ini /data/rutorrent/conf/plugins.ini
  ln -sf /data/rutorrent/conf/plugins.ini /var/www/rutorrent/conf/plugins.ini
fi
chown rtorrent:rtorrent /data/rutorrent/conf/plugins.ini

# Remove ruTorrent core plugins
if [ "$RU_REMOVE_CORE_PLUGINS" != "false" ]; then
  for i in ${RU_REMOVE_CORE_PLUGINS//,/ }
  do
    if [ -z "$i" ]; then continue; fi
    if [ "$i" == "httprpc" ]; then
      echo "Warning: skipping core plugin httprpc, required for ruTorrent v4.3+ operation"
      echo "Please remove httprpc from RU_REMOVE_CORE_PLUGINS environment varriable"
      continue;
    fi      
    echo "Removing core plugin $i..."
    rm -rf "/var/www/rutorrent/plugins/${i}"
  done
fi

echo "Setting custom config for create plugin..."
if [ -d "/var/www/rutorrent/plugins/create" ]; then

  cat > /var/www/rutorrent/plugins/create/conf.php <<EOL
<?php

\$useExternal = 'mktorrent';
\$pathToCreatetorrent = '/usr/local/bin/mktorrent';
\$recentTrackersMaxCount = 15;
\$useInternalHybrid = true;
EOL
  chown nobody:nogroup "/var/www/rutorrent/plugins/create/conf.php"
else
  echo "  WARNING: create plugin does not exist"
fi

echo "Checking ruTorrent custom plugins..."
plugins=$(ls -l /data/rutorrent/plugins | grep -E '^d' | awk '{print $9}')
for plugin in ${plugins}; do
  if [ "${plugin}" = "theme" ]; then
    echo "  WARNING: theme plugin cannot be overriden"
    continue
  fi
  echo "  Copying custom ${plugin} plugin..."
  if [ -d "/var/www/rutorrent/plugins/${plugin}" ]; then
    rm -rf "/var/www/rutorrent/plugins/${plugin}"
  fi
  cp -Rf "/data/rutorrent/plugins/${plugin}" "/var/www/rutorrent/plugins/${plugin}"
  chown -R nobody:nogroup "/var/www/rutorrent/plugins/${plugin}"
done

echo "Checking ruTorrent plugins configuration..."
for pluginConfFile in /data/rutorrent/plugins-conf/*.php; do
  if [ ! -f "$pluginConfFile" ]; then
    continue
  fi
  pluginConf=$(basename "$pluginConfFile")
  pluginName=$(echo "$pluginConf" | cut -f 1 -d '.')
  if [ ! -d "/var/www/rutorrent/plugins/${pluginName}" ]; then
    echo "  WARNING: $pluginName plugin does not exist"
    continue
  fi
  if [ -d "/data/rutorrent/plugins/${pluginName}" ]; then
    echo "  WARNING: $pluginName plugin already exist in /data/rutorrent/plugins/"
    continue
  fi
  echo "  Copying ${pluginName} plugin config..."
  cp -f "${pluginConfFile}" "/var/www/rutorrent/plugins/${pluginName}/conf.php"
  chown nobody:nogroup "/var/www/rutorrent/plugins/${pluginName}/conf.php"
done

echo "Checking ruTorrent custom themes..."
themes=$(ls -l /data/rutorrent/themes | grep -E '^d' | awk '{print $9}')
for theme in ${themes}; do
  echo "  Copying custom ${theme} theme..."
  if [ -d "/var/www/rutorrent/plugins/theme/themes/${theme}" ]; then
    rm -rf "/var/www/rutorrent/plugins/theme/themes/${theme}"
  fi
  cp -Rf "/data/rutorrent/themes/${theme}" "/var/www/rutorrent/plugins/theme/themes/${theme}"
  chown -R nobody:nogroup "/var/www/rutorrent/plugins/theme/themes/${theme}"
done

echo "Setting GeoIP2 databases for geoip2 plugin..."
if [ -d "/var/www/rutorrent/plugins/geoip2" ]; then
  if [ ! "$(ls -A /data/geoip)" ]; then
    cp -f /var/mmdb/*.mmdb /data/geoip/
  fi
  ln -sf /data/geoip/GeoLite2-ASN.mmdb /var/www/rutorrent/plugins/geoip2/database/GeoLite2-ASN.mmdb
  ln -sf /data/geoip/GeoLite2-City.mmdb /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City.mmdb
  ln -sf /data/geoip/GeoLite2-Country.mmdb /var/www/rutorrent/plugins/geoip2/database/GeoLite2-Country.mmdb
else
  echo "  WARNING: geoip2 plugin does not exist"
fi

echo "Fixing perms..."
chown rtorrent:rtorrent \
  /data/rutorrent/share/users \
  /data/rutorrent/share/torrents \
  /downloads \
  /downloads/complete \
  /downloads/temp \
  "${RU_LOG_FILE}"
chown -R rtorrent:rtorrent \
  /data/geoip \
  /data/rtorrent/log \
  /data/rtorrent/.session \
  /data/rtorrent/watch \
  /data/rutorrent/conf \
  /data/rutorrent/plugins \
  /data/rutorrent/plugins-conf \
  /data/rutorrent/share \
  /data/rutorrent/themes \
  /etc/rtorrent
chmod 644 \
  /data/rtorrent/.rtorrent.rc \
  /passwd/*.htpasswd \
  /etc/rtorrent/.rtlocal.rc
