#!/bin/sh

# Htpasswd ?
if [ "$1" == "htpasswd" ]; then
  exec "$@" || exit 0
fi

export WAN_IP=${WAN_IP:-$(dig +short myip.opendns.com @resolver1.opendns.com)}

export RTORRENT_HOME="/data/rtorrent"
export RTORRENT_RUN_PATH="/run/rtorrent"

export RUTORRENT_HOME="/data/rutorrent"

export PASSWD_PATH="/passwd"

TZ=${TZ:-UTC}
PUID=${PUID:-1000}
PGID=${PGID:-1000}

MEMORY_LIMIT=${MEMORY_LIMIT:-256M}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-16M}
OPCACHE_MEM_SIZE=${OPCACHE_MEM_SIZE:-128}
REAL_IP_FROM=${REAL_IP_FROM:-0.0.0.0/32}
REAL_IP_HEADER=${REAL_IP_HEADER:-X-Forwarded-For}
LOG_IP_VAR=${LOG_IP_VAR:-remote_addr}

XMLRPC_AUTHBASIC_STRING=${XMLRPC_AUTHBASIC_STRING:-rTorrent XMLRPC restricted access}
RUTORRENT_AUTHBASIC_STRING=${RUTORRENT_AUTHBASIC_STRING:-ruTorrent restricted access}
WEBDAV_AUTHBASIC_STRING=${WEBDAV_AUTHBASIC_STRING:-WebDAV restricted access}

RT_LOG_LEVEL=${RT_LOG_LEVEL:-info}
RT_LOG_EXECUTE=${RT_LOG_EXECUTE:-false}
RT_LOG_XMLRPC=${RT_LOG_XMLRPC:-false}

RU_REMOVE_CORE_PLUGINS=${RU_REMOVE_CORE_PLUGINS:-erasedata,httprpc}
RU_HTTP_USER_AGENT=${RU_HTTP_USER_AGENT:-Mozilla/5.0 (Windows NT 6.0; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0}
RU_HTTP_TIME_OUT=${RU_HTTP_TIME_OUT:-30}
RU_HTTP_USE_GZIP=${RU_HTTP_USE_GZIP:-true}
RU_RPC_TIME_OUT=${RU_RPC_TIME_OUT:-5}
RU_LOG_RPC_CALLS=${RU_LOG_RPC_CALLS:-false}
RU_LOG_RPC_FAULTS=${RU_LOG_RPC_FAULTS:-true}
RU_PHP_USE_GZIP=${RU_PHP_USE_GZIP:-false}
RU_PHP_GZIP_LEVEL=${RU_PHP_GZIP_LEVEL:-2}
RU_SCHEDULE_RAND=${RU_SCHEDULE_RAND:-10}
RU_LOG_FILE=${RU_LOG_FILE:-$RUTORRENT_HOME/rutorrent.log}
RU_DO_DIAGNOSTIC=${RU_DO_DIAGNOSTIC:-true}
RU_SAVE_UPLOADED_TORRENTS=${RU_SAVE_UPLOADED_TORRENTS:-true}
RU_OVERWRITE_UPLOADED_TORRENTS=${RU_OVERWRITE_UPLOADED_TORRENTS:-false}
RU_FORBID_USER_SETTINGS=${RU_FORBID_USER_SETTINGS:-false}
RU_LOCALE=${RU_LOCALE:-UTF8}

# Timezone
echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# Change rtorrent UID / GID
echo "Checking if rtorrent UID / GID has changed..."
if [ $(id -u rtorrent) != ${PUID} ]; then
  usermod -u ${PUID} rtorrent
fi
if [ $(id -g rtorrent) != ${PGID} ]; then
  groupmod -g ${PGID} rtorrent
fi

# PHP
echo "Setting PHP-FPM configuration..."
sed -e "s/@MEMORY_LIMIT@/$MEMORY_LIMIT/g" \
  -e "s/@UPLOAD_MAX_SIZE@/$UPLOAD_MAX_SIZE/g" \
  /tpls/etc/php7/php-fpm.d/www.conf > /etc/php7/php-fpm.d/www.conf

# OpCache
echo "Setting OpCache configuration..."
sed -e "s/@OPCACHE_MEM_SIZE@/$OPCACHE_MEM_SIZE/g" \
  /tpls/etc/php7/conf.d/opcache.ini > /etc/php7/conf.d/opcache.ini

# Nginx
echo "Setting Nginx configuration..."
sed -e "s#@REAL_IP_FROM@#$REAL_IP_FROM#g" \
  -e "s#@REAL_IP_HEADER@#$REAL_IP_HEADER#g" \
  -e "s#@LOG_IP_VAR@#$LOG_IP_VAR#g" \
  /tpls/etc/nginx/nginx.conf > /etc/nginx/nginx.conf

# Nginx XMLRPC over SCGI
echo "Setting Nginx XMLRPC over SCGI configuration..."
sed -e "s!@RTORRENT_RUN_PATH@!$RTORRENT_RUN_PATH!g" \
  -e "s!@PASSWD_PATH@!$PASSWD_PATH!g" \
  -e "s!@XMLRPC_AUTHBASIC_STRING@!$XMLRPC_AUTHBASIC_STRING!g" \
  /tpls/etc/nginx/conf.d/rpc.conf > /etc/nginx/conf.d/rpc.conf

# Nginx ruTorrent
echo "Setting Nginx ruTorrent configuration..."
sed -e "s!@PASSWD_PATH@!$PASSWD_PATH!g" \
  -e "s!@UPLOAD_MAX_SIZE@!$UPLOAD_MAX_SIZE!g" \
  -e "s!@RUTORRENT_AUTHBASIC_STRING@!$RUTORRENT_AUTHBASIC_STRING!g" \
  /tpls/etc/nginx/conf.d/rutorrent.conf > /etc/nginx/conf.d/rutorrent.conf

# Nginx WebDAV
echo "Setting Nginx WebDAV configuration..."
sed -e "s!@RTORRENT_HOME@!$RTORRENT_HOME!g" \
  -e "s!@PASSWD_PATH@!$PASSWD_PATH!g" \
  -e "s!@WEBDAV_AUTHBASIC_STRING@!$WEBDAV_AUTHBASIC_STRING!g" \
  /tpls/etc/nginx/conf.d/webdav.conf > /etc/nginx/conf.d/webdav.conf

# Init
echo "Initializing files and folders..."
mkdir -p ${PASSWD_PATH} \
  ${RTORRENT_HOME}/downloads/complete \
  ${RTORRENT_HOME}/downloads/temp \
  ${RTORRENT_HOME}/log \
  ${RTORRENT_HOME}/.session \
  ${RTORRENT_HOME}/watch \
  ${RUTORRENT_HOME}/conf/users \
  ${RUTORRENT_HOME}/plugins \
  ${RUTORRENT_HOME}/plugins-conf \
  ${RUTORRENT_HOME}/share/users \
  ${RUTORRENT_HOME}/themes \
  /run/rtorrent
touch ${PASSWD_PATH}/rpc.htpasswd \
  ${PASSWD_PATH}/rutorrent.htpasswd \
  ${PASSWD_PATH}/webdav.htpasswd \
  ${RTORRENT_HOME}/log/rtorrent.log \
  ${RU_LOG_FILE}
rm -f ${RTORRENT_HOME}/.session/rtorrent.lock

# Check htpasswd files
if [ ! -s "${PASSWD_PATH}/rpc.htpasswd" ]; then
  echo "rpc.htpasswd is empty, removing authentication..."
  sed -i "s!auth_basic .*!#auth_basic!g" /etc/nginx/conf.d/rpc.conf
  sed -i "s!auth_basic_user_file.*!#auth_basic_user_file!g" /etc/nginx/conf.d/rpc.conf
fi
if [ ! -s "${PASSWD_PATH}/rutorrent.htpasswd" ]; then
  echo "rutorrent.htpasswd is empty, removing authentication..."
  sed -i "s!auth_basic .*!#auth_basic!g" /etc/nginx/conf.d/rutorrent.conf
  sed -i "s!auth_basic_user_file.*!#auth_basic_user_file!g" /etc/nginx/conf.d/rutorrent.conf
fi
if [ ! -s "${PASSWD_PATH}/webdav.htpasswd" ]; then
  echo "webdav.htpasswd is empty, removing authentication..."
  sed -i "s!auth_basic .*!#auth_basic!g" /etc/nginx/conf.d/webdav.conf
  sed -i "s!auth_basic_user_file.*!#auth_basic_user_file!g" /etc/nginx/conf.d/webdav.conf
fi

# rTorrent local config
echo "Checking rTorrent local configuration..."
sed -e "s!@RT_LOG_LEVEL@!$RT_LOG_LEVEL!g" \
  /tpls/etc/.rtlocal.rc > /etc/.rtlocal.rc
if [ "${RT_LOG_EXECUTE}" == "true" ]; then
  echo "  Enabling rTorrent execute log..."
  sed -i "s!#log\.execute.*!log\.execute = (cat,(cfg.logs),\"execute.log\")!g" /etc/.rtlocal.rc
fi
if [ "${RT_LOG_XMLRPC}" == "true" ]; then
  echo "  Enabling rTorrent xmlrpc log..."
  sed -i "s!#log\.xmlrpc.*!log\.xmlrpc = (cat,(cfg.logs),\"xmlrpc.log\")!g" /etc/.rtlocal.rc
fi

# rTorrent config
echo "Checking rTorrent configuration..."
if [ ! -f ${RTORRENT_HOME}/.rtorrent.rc ]; then
  echo "  Creating default configuration..."
  cp /tpls/.rtorrent.rc ${RTORRENT_HOME}/.rtorrent.rc
fi

# ruTorrent config
echo "Bootstrapping ruTorrent configuration..."
cat > /var/www/rutorrent/conf/config.php <<EOL
<?php

// For snoopy client
@define('HTTP_USER_AGENT', '${RU_HTTP_USER_AGENT}', true);
@define('HTTP_TIME_OUT', ${RU_HTTP_TIME_OUT}, true);
@define('HTTP_USE_GZIP', ${RU_HTTP_USE_GZIP}, true);

@define('RPC_TIME_OUT', ${RU_RPC_TIME_OUT}, true);

@define('LOG_RPC_CALLS', ${RU_LOG_RPC_CALLS}, true);
@define('LOG_RPC_FAULTS', ${RU_LOG_RPC_FAULTS}, true);

// For php
@define('PHP_USE_GZIP', ${RU_PHP_USE_GZIP}, true);
@define('PHP_GZIP_LEVEL', ${RU_PHP_GZIP_LEVEL}, true);

// Rand for schedulers start, +0..X seconds
\$schedule_rand = ${RU_SCHEDULE_RAND};

// Path to log file (comment or leave blank to disable logging)
\$log_file = '${RU_LOG_FILE}';
\$do_diagnostic = ${RU_DO_DIAGNOSTIC};

// Save uploaded torrents to profile/torrents directory or not
\$saveUploadedTorrents = ${RU_SAVE_UPLOADED_TORRENTS};

// Overwrite existing uploaded torrents in profile/torrents directory or make unique name
\$overwriteUploadedTorrents = ${RU_OVERWRITE_UPLOADED_TORRENTS};

// Upper available directory. Absolute path with trail slash.
\$topDirectory = '/data';
\$forbidUserSettings = ${RU_FORBID_USER_SETTINGS};

// For web->rtorrent link through unix domain socket
\$scgi_port = 0;
\$scgi_host = "unix://${RTORRENT_RUN_PATH}/scgi.socket";
\$XMLRPCMountPoint = "/RPC2"; // DO NOT DELETE THIS LINE!!! DO NOT COMMENT THIS LINE!!!

\$pathToExternals = array(
    "php"   => '',
    "curl"  => '',
    "gzip"  => '',
    "id"    => '',
    "stat"  => '',
);

// List of local interfaces
\$localhosts = array(
    "127.0.0.1",
    "localhost",
);

// Path to user profiles
\$profilePath = '${RUTORRENT_HOME}/share';
// Mask for files and directory creation in user profiles.
\$profileMask = 0770;

// Temp directory. Absolute path with trail slash. If null, then autodetect will be used.
\$tempDirectory = null;

// If true then use X-Sendfile feature if it exist
\$canUseXSendFile = false;

\$locale = '${RU_LOCALE}';
EOL
chown nginx. /var/www/rutorrent/conf/config.php

# Symlinking ruTorrent config
ln -sf ${RUTORRENT_HOME}/conf/users /var/www/rutorrent/conf/users
if [ ! -f ${RUTORRENT_HOME}/conf/access.ini ]; then
  echo "Symlinking ruTorrent access.ini file..."
  mv /var/www/rutorrent/conf/access.ini ${RUTORRENT_HOME}/conf/access.ini
  ln -sf ${RUTORRENT_HOME}/conf/access.ini /var/www/rutorrent/conf/access.ini
fi
if [ ! -f ${RUTORRENT_HOME}/conf/plugins.ini ]; then
  echo "Symlinking ruTorrent plugins.ini file..."
  mv /var/www/rutorrent/conf/plugins.ini ${RUTORRENT_HOME}/conf/plugins.ini
  ln -sf ${RUTORRENT_HOME}/conf/plugins.ini /var/www/rutorrent/conf/plugins.ini
fi

# Remove ruTorrent core plugins
for i in ${RU_REMOVE_CORE_PLUGINS//,/ }
do
  if [ -z "$i" ]; then continue; fi
  echo "Removing core plugin $i..."
  rm -rf /var/www/rutorrent/plugins/${i}
done

# Override ruTorrent plugins config
echo "Overriding ruTorrent plugins config (create)..."
cat > /var/www/rutorrent/plugins/create/conf.php <<EOL
<?php

\$useExternal = 'mktorrent';
\$pathToCreatetorrent = '/usr/local/bin/mktorrent';
\$recentTrackersMaxCount = 15;
EOL
chown nginx. /var/www/rutorrent/plugins/create/conf.php

# Check ruTorrent plugins
echo "Checking ruTorrent custom plugins..."
plugins=$(ls -l ${RUTORRENT_HOME}/plugins | egrep '^d' | awk '{print $9}')
for plugin in ${plugins}; do
  if [ "${plugin}" == "theme" ]; then
    echo "  WARNING: Plugin theme cannot be overriden"
    continue
  fi
  echo "  Copying custom plugin ${plugin}..."
  rm -rf "/var/www/rutorrent/plugins/${plugin}"
  cp -Rf "${RUTORRENT_HOME}/plugins/${plugin}" "/var/www/rutorrent/plugins/${plugin}"
  chown -R rtorrent. "/var/www/rutorrent/plugins/${plugin}"
done

# Check ruTorrent plugins config
echo "Checking ruTorrent plugins configuration..."
for pluginConfFile in ${RUTORRENT_HOME}/plugins-conf/*.php; do
  if [ ! -f "$pluginConfFile" ]; then
    continue
  fi
  pluginConf=$(basename "$pluginConfFile")
  pluginName=$(echo "$pluginConf" | cut -f 1 -d '.')
  if [ ! -d "/var/www/rutorrent/plugins/${pluginName}" ]; then
    echo "  WARNING: Plugin $pluginName does not exist"
    continue
  fi
  if [ -d "${RUTORRENT_HOME}/plugins/${pluginName}" ]; then
    echo "  WARNING: Plugin $pluginName already present in ${RUTORRENT_HOME}/plugins/"
    continue
  fi
  echo "  Copying ${pluginName} plugin config..."
  cp -f "${pluginConfFile}" "/var/www/rutorrent/plugins/${pluginName}/conf.php"
  chown rtorrent. "/var/www/rutorrent/plugins/${pluginName}/conf.php"
done

# Check ruTorrent themes
echo "Checking ruTorrent custom themes..."
themes=$(ls -l ${RUTORRENT_HOME}/themes | egrep '^d' | awk '{print $9}')
for theme in ${themes}; do
  echo "  Copying custom theme ${theme}..."
  rm -rf "/var/www/rutorrent/plugins/theme/themes/${theme}"
  cp -Rf "${RUTORRENT_HOME}/themes/${theme}" "/var/www/rutorrent/plugins/theme/themes/${theme}"
  chown -R rtorrent. "/var/www/rutorrent/plugins/theme/themes/${theme}"
done

# Perms
echo "Fixing permissions..."
chown -R rtorrent. /data /etc/.rtlocal.rc /run/rtorrent
chown -R nginx. /passwd
chmod 644 ${RTORRENT_HOME}/.rtorrent.rc ${PASSWD_PATH}/*.htpasswd /etc/.rtlocal.rc

exec "$@"
