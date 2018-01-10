#!/bin/sh

export WAN_IP=${WAN_IP:=$(dig +short myip.opendns.com @resolver1.opendns.com)}

# Timezone
ln -snf /usr/share/zoneinfo/${TZ:-"UTC"} /etc/localtime
echo ${TZ:-"UTC"} > /etc/timezone

# Change user UID / GID
usermod -u ${UID:=1000} rtorrent
groupmod -g ${GID:=1000} rtorrent

# Init
mkdir -p ${HOME_PATH}/.log
mkdir -p ${HOME_PATH}/.session
mkdir -p ${HOME_PATH}/.watch
mkdir -p ${HOME_PATH}/downloads/complete
mkdir -p ${HOME_PATH}/downloads/temp
touch ${HOME_PATH}/.log/rtorrent.log

# Perms
chown -R rtorrent. ${HOME_PATH}
chmod 644 ${HOME_PATH}/.rtorrent.rc

exec "$@"
