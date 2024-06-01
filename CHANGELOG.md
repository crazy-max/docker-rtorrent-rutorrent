# Changelog

## 4.3.2-3.1-r0 (2024/06/01)

* rTorrent v3.1 (#355)

## 4.3.2-3.0-r0 (2024/05/27)

* ruTorrent v4.3.2 (#344)
* Switch to [rTorrent stickz](https://github.com/stickz/rtorrent) repo (#347)
* Disable listening for IPv6 ofr nginx (#349)

## 4.3.1-0.9.8_3-0.13.8_2-r0 (2024/05/17)

* ruTorrent v4.3.1 (#344)
* Disallow ruTorrent `httprpc` core plugin removal (#346)

## 4.3.0-0.9.8_3-0.13.8_2-r0 (2024/05/01)

* Set `useInternalHybrid` ruTorrent setting to `true` (#341) 
* Fix missing changes in `.rtlocal.rc` (#338)

## 4.3.0-0.9.8_2-0.13.8_2-r0 (2024/04/27)

* ruTorrent v4.3.0 (#327 #316)
* rTorrent: Add TCP socket configurations (#322)
* Add `php82-fileinfo` package (#325)
* rTorrent: Set of patches to fix memory leaks (#308)
* rTorrent: Fix memory access crash (#310)

## 4.2.9-0.9.8_2-0.13.8_2-r0 (2023/12/27)

* UDNS support (#303)
* Fix PHP version in rtlocal.rc (#305)

## 4.2.9-0.9.8_2-0.13.8_1-r0 (2023/12/23)

* rTorrent: tracker scrape feature patch (#288)
* Alpine Linux 3.19 and PHP 8.2 (#297)
* cURL 8.5.0, c-ares 1.24.0 (#295)

## 4.2.9-0.9.8_1-0.13.8_1-r0 (2023/12/17)

* rTorrent patches
  * Avoid stack overflow for lockfile buffer
  * Increase maximum SCGI request to 16MB
  * Fix saving session files
  * Fix a common rtorrent xml-rpc crash when trying to queue an invalid task
  * Resolve xmlrpc logic crash
* libtorrent patches
  * Allow 10 gigabit speed throttles

## 4.2.9-0.9.8-0.13.8-r0 (2023/11/18)

* ruTorrent v4.2.9 (#282)

## 4.2.6-0.9.8-0.13.8-r0 (2023/09/24)

* ruTorrent v4.2.6 (#266)

## 4.2.5-0.9.8-0.13.8-r0 (2023/08/29)

* ruTorrent v4.2.5 (#263)

## 4.2.2-0.9.8-0.13.8-r0 (2023/08/13)

* ruTorrent v4.2.2 (#260)

## 4.1.7-0.9.8-0.13.8-r0 (2023/08/01)

* ruTorrent v4.1.7 (#251 #248)
* Alpine Linux 3.18 (#258)

## 4.1.5-0.9.8-0.13.8-r1 (2023/05/17)

* Improve session saving in rTorrent (#242)

## 4.1.5-0.9.8-0.13.8-r0 (2023/05/02)

* ruTorrent v4.1.5 (#238)
* Optimize cURL build (#239)
* Add `php81-dom` extension (#237)

## 4.1.3-0.9.8-0.13.8-r0 (2023/04/27)

* ruTorrent v4.1.3 (#235)

## 4.0.4-0.9.8-0.13.8-r0 (2023/04/10)

* ruTorrent v4.0.4 (#231)
* Fix `RU_REMOVE_CORE_PLUGINS` defaults (#230)
* Remove erase data workaround (#229)
* Improve watch directory support (#219)

## 4.0.2-0.9.8-0.13.8-r0 (2023/02/21)

* ruTorrent v4.0.2-hotfix (#218)

## 4.0.1-0.9.8-0.13.8-r1 (2023/02/05)

* Set `$localHostedMode = true` (#215)

## 4.0.1-0.9.8-0.13.8-r0 (2023/01/29)

* ruTorrent v4.0.1-hotfix (#214)

## 4.0-0.9.8-0.13.8-r0 (2023/01/11)

* ruTorrent v4.0-stable (#208)
* Update GeoIP2 ruTorrent plugin (#211)
* Fix nginx logs folder perms (#207)

## 3.10-0.9.8-0.13.8-r23 (2023/01/07)

* Fix PHP version in `.rtlocal.rc` (#204)
* Make rtorrent and libtorrent with `-O2 -flto` (#202)

## 3.10-0.9.8-0.13.8-r22 (2023/01/02)

* Install nginx and webdav module from Alpine repo (#200)
* Fix xmlrpc-c build configuration (#198)

## 3.10-0.9.8-0.13.8-r21 (2022/12/31)

* Set `S6_KILL_GRACETIME` to 10 seconds (#171)
* Alpine Linux 3.17 (#195)
* PHP 8.1 (#195)
* GeoIP2 PHP extension 1.3.1 (#195)
* Nginx 1.22.1 (#195)

## 3.10-0.9.8-0.13.8-r20 (2022/05/02)

* Fix unrar not available since alpine 3.15 (#161)

## 3.10-0.9.8-0.13.8-r19 (2022/04/29)

* Fix GeoIP2 ruTorrent plugin version (#159)
* Optimize Dockerfile (#157)

## 3.10-0.9.8-0.13.8-r18 (2022/04/28)

* Opt-in `WAN_IP` and add `WAN_IP_CMD` env var (#150 #153)
* Check plugins existence (#155)
* Option to disable Nginx access log (#154)
* Alpine Linux 3.15 (#151)
* Use GitHub Actions cache backend (#152)

## 3.10-0.9.8-0.13.8-r17 (2021/08/19)

* Update dependencies (#117)
* Alpine Linux 3.14 (#116)

## 3.10-0.9.8-0.13.8-r16 (2021/08/01)

* Fix Traefik example (#113)
* Add `AUTH_DELAY` env var (#109)  
* Add `XMLRPC_SIZE_LIMIT` env var (#107)

## 3.10-0.9.8-0.13.8-r15 (2021/06/14)

* Add `posix` PHP extension (#102)

## 3.10-0.9.8-0.13.8-r14 (2021/05/31)

* `ifconfig.me` as fallback for automatic WAN_IP determination (#96)

## 3.10-0.9.8-0.13.8-r13 (2021/04/13)

* Dynamically manage healthcheck ports (#76)

## 3.10-0.9.8-0.13.8-r12 (2021/04/11)

* Initialize ruTorrent plugins (#74)

## 3.10-0.9.8-0.13.8-r11 (2021/04/11)

* Allow ports customization (#73)

## 3.10-0.9.8-0.13.8-r10 (2021/03/27)

* Add `findutils` package (#67)

## 3.10-0.9.8-0.13.8-r9 (2021/03/21)

* [alpine-s6](https://github.com/crazy-max/docker-alpine-s6/) 3.12-2.2.0.3 (#61)
* cURL 7.68.0

## 3.10-0.9.8-0.13.8-r8 (2021/03/18)

* Upstream Alpine update
* Add support for `linux/arm/v6`

## 3.10-0.9.8-0.13.8-r7 (2021/03/17)

* Multi-platform image (#60)

## 3.10-0.9.8-0.13.8-r6 (2021/03/06)

* Fix auth for ruTorrent and add global `auth_basic` (#53)

## 3.10-0.9.8-0.13.8-r5 (2021/03/05)

* Add `bash` (#52)

## 3.10-0.9.8-0.13.8-r4 (2021/02/22)

* Fix permissions issue
* Review Dockerfile

## 3.10-0.9.8-0.13.8-r3 (2021/02/14)

* ruTorrent 3.10 rev [Novik/ruTorrent@954479f](https://github.com/Novik/ruTorrent/commit/954479ffd00eb58ad14f9a667b3b9b1e108e80a2)
* Do not fail on permission issue
* Switch to buildx bake
* Update mmdb links
* Publish to GHCR
* Allow to clear env for FPM workers
* Traefik v2 example

## 3.10-0.9.8-0.13.8-RC2 (2020/09/23)

* Fix Cloudflare plugin

## 3.10-0.9.8-0.13.8-RC1 (2020/06/26)

* ruTorrent 3.10 rev [Novik/ruTorrent@3446d5a](https://github.com/Novik/ruTorrent/commit/3446d5ae5fb44e5e1517d5bd600ebe3064fea82c)
* XMLRPC 01.58.00
* Libsig 3.0.3
* cURL 7.71.0

## 3.9-0.9.8-0.13.8-RC16 (2020/05/21)

* Add `MAX_FILE_UPLOADS` environment variable (#22)

## 3.9-0.9.8-0.13.8-RC15 (2020/04/27)

* Move downloads to a dedicated volume (#20)
* Switch to Open Container Specification labels as label-schema.org ones are deprecated

> :warning: **UPGRADE NOTES**
> Downloads folder has moved from `/data/rtorrent/downloads` to `/downloads`<br />
> If you have active torrents, it is recommended to create a symlink from your rtorrent folder on your host:<br />
> `cd ./data/rtorrent/ && ln -sf ../../downloads ./` 

## 3.9-0.9.8-0.13.8-RC14 (2020/03/27)

* Fix folder creation

## 3.9-0.9.8-0.13.8-RC13 (2020/01/24)

* Move Nginx temp folders to `/tmp`

## 3.9-0.9.8-0.13.8-RC12 (2020/01/02)

* Use [geoip-updater](https://github.com/crazy-max/geoip-updater) Docker image to download MaxMind's GeoIP2 databases

## 3.9-0.9.8-0.13.8-RC11 (2019/12/07)

* Fix timezone

## 3.9-0.9.8-0.13.8-RC10 (2019/11/23)

* Dedicated container for rtorrent logs

## 3.9-0.9.8-0.13.8-RC9 (2019/11/23)

* `.rtorrent.rc` not taken into account

## 3.9-0.9.8-0.13.8-RC8 (2019/11/22)

* Switch to [s6-overlay](https://github.com/just-containers/s6-overlay/) as a process supervisor
* Add `PUID`/`PGID` vars (#12)
* Do not set defaults if `RU_REMOVE_CORE_PLUGINS` is empty
* Nginx mainline base image

## 3.9-0.9.8-0.13.8-RC7 (2019/10/26)

* Base image update

## 3.9-0.9.8-0.13.8-RC6 (2019/10/25)

* Fix CVE-2019-11043

## 3.9-0.9.8-0.13.8-RC5 (2019/10/17)

* Remove `PUID` / `PGID` vars

## 3.9-0.9.8-0.13.8-RC4 (2019/10/16)

* Switch to GitHub Actions
* Stop publishing Docker image on Quay
* Move bootstrap (default) config for rTorrent to `/etc/rtorrent/.rtlocal.rc`
* Run as non-root user
* Prevent exposing nginx version
* Set timezone through tzdata

> :warning: **UPGRADE NOTES**
> As the Docker container now runs as a non-root user, you have to first stop the container and change permissions to volumes:
> ```
> docker compose stop
> chown -R 1000:1000 data/ passwd/
> docker compose pull
> docker compose up -d
> ```

## 3.9-0.9.8-0.13.8-RC3 (2019/09/04)

* Create `share/torrents` for ruTorrent

## 3.9-0.9.8-0.13.8-RC2 (2019/08/07)

* Add healthcheck
* Allow directory listing for WebDAV
* Remove php-fpm access log (already mirrored by nginx)

## 3.9-0.9.8-0.13.8-RC1 (2019/07/22)

* ruTorrent 3.9 rev [Novik/ruTorrent@ec8d8f1](https://github.com/Novik/ruTorrent/commit/ec8d8f1887af57793a671258072b59193a5d8d6c)
* rTorrent 0.9.8 and libTorrent 0.13.8
* XMLRPC 01.55.00
* cURL 7.65.3

## 3.9-0.9.7-0.13.7-RC3 (2019/04/28)

* Add `large_client_header_buffers` Nginx config

## 3.9-0.9.7-0.13.7-RC2 (2019/04/15)

* Add `REAL_IP_FROM`, `REAL_IP_HEADER` and `LOG_IP_VAR` environment variables

## 3.9-0.9.7-0.13.7-RC1 (2019/04/09)

* ruTorrent 3.9

## 3.8-0.9.7-0.13.7-RC7 (2019/01/14)

* Add mktorrent for ruTorrent create plugin
* Replace core ruTorrent GeoIP plugin with [GeoIP2 plugin](https://github.com/Micdu70/geoip2-rutorrent)

## 3.8-0.9.7-0.13.7-RC6 (2019/01/09)

* Allow to customize auth basic string (Issue #5)

## 3.8-0.9.7-0.13.7-RC5 (2019/01/08)

* Bind ruTorrent HTTP port to unprivileged port : `8080`
* Fix Nginx WebDAV module version
* Update ruTorrent to Novik/ruTorrent@4d3029c
* Update libs (XMLRPC, Libsig, cURL)

## 3.8-0.9.7-0.13.7-RC4 (2018/12/04)

* Nginx `default.conf` overrides our conf (Issue #1)

## 3.8-0.9.7-0.13.7-RC3 (2018/12/03)

* Based on `nginx:stable-alpine`
* Optimize layers

## 3.8-0.9.7-0.13.7-RC2 (2018/06/26)

* Include path error for custom plugins and themes

## 3.8-0.9.7-0.13.7-RC1 (2018/06/25)

* Add ruTorrent 3.8 web client
* Add option to remove core plugins of ruTorrent (default `erasedata,httprpc`)
* Add a bootstrap (default) config for rTorrent in `/etc/.rtlocal.rc`
* Move `/var/rtorrent` to `/data/rtorrent`
* Use Nginx WebDAV module instead of Apache
* Compile Nginx from source for better performance
* Remove Apache2 and implement Nginx WebDAV
* Do not process entrypoint on `htpasswd` command
* Add reverse proxy example with Traefik
* Remove old docker tags `0.9.6-0.13.6` and `0.9.7-0.13.7`
* Do not persist runtime data
* Rename repository `rtorrent-rutorrent` (github and docker hub)

## 0.9.7-0.13.7-RC3 (2018/06/18)

* Force rTorrent process as a daemon through command flag
* Add .rtorrent.rc if not exist

## 0.9.7-0.13.7-RC2 (2018/06/17)

* Move runtime data in `/var/rtorrent/run`
* Enable WebDAV protocol on `/downloads/complete` with basic auth

## 0.9.7-0.13.7-RC1 (2018/06/16)

* rTorrent 0.9.7 and libTorrent 0.13.7
* Base image updated to Alpine Linux 3.7
* c-ares 1.14.0
* curl 7.60.0
* Move `RTORRENT_HOME` to `/var/rtorrent`
* XMLRPC through nginx over SCGI socket with basic auth
* Do not expose SCGI port (use a local socket instead)
* Run the rTorrent process as a daemon
* Replace deprecated commands in `.rtorrent.rc`
* Review supervisor config

## 0.9.6-0.13.6-RC1 (2018/01/10)

* Initial version
