# Changelog

## 0.9.7-0.13.7-RC1 (2018/06/16)

* Upgrade to rTorrent 0.9.7 and libTorrent 0.13.7
* Base image updated to Alpine 3.7
* Update c-ares to 1.14.0
* Update curl to 7.60.0
* Move `RTORRENT_HOME` to `/var/rtorrent`
* XMLRPC through nginx over SCGI socket with basic auth
* Do not expose SCGI port (use a local socket instead)
* Run the rTorrent process as a daemon
* Replace deprecated commands in `.rtorrent.rc`
* Review supervisor config

## 0.9.6-0.13.6-RC1 (2018/01/10)

* Initial version
