#!/usr/bin/with-contenv sh
# shellcheck shell=sh

/usr/bin/kill -s 15 `cat /var/run/rtorrent/rtorrent.pid`