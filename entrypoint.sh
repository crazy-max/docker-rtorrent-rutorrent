#!/bin/sh

TZ=${TZ:-"UTC"}
RTORRENT_HOME=${RTORRENT_HOME:-"/var/rtorrent"}
PUID=${PUID:-1000}
PGID=${PGID:-1000}

export WAN_IP=${WAN_IP:=$(dig +short myip.opendns.com @resolver1.opendns.com)}

# Timezone
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# Change rtorrent UID / GID
if [ $(id -u rtorrent) != ${PUID} ]; then
  usermod -u ${PUID} rtorrent
fi
if [ $(id -g rtorrent) != ${PGID} ]; then
  groupmod -g ${PGID} rtorrent
fi

# Init
mkdir -p ${RTORRENT_HOME}/downloads/complete \
  ${RTORRENT_HOME}/downloads/temp \
  ${RTORRENT_HOME}/log \
  ${RTORRENT_HOME}/.session \
  ${RTORRENT_HOME}/watch \
  /run/rtorrent
touch ${RTORRENT_HOME}/rpc.htpasswd

# Perms
chown -R rtorrent. ${RTORRENT_HOME} /run/rtorrent
chmod 644 ${RTORRENT_HOME}/.rtorrent.rc

exec "$@"
