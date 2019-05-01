<p align="center"><a href="https://github.com/crazy-max/docker-rtorrent-rutorrent" target="_blank"><img height="128"src="https://raw.githubusercontent.com/crazy-max/docker-rtorrent-rutorrent/master/.res/docker-rtorrent-rutorrent.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/rtorrent-rutorrent/"><img src="https://img.shields.io/badge/dynamic/json.svg?label=version&query=$.results[1].name&url=https://hub.docker.com/v2/repositories/crazymax/rtorrent-rutorrent/tags&style=flat-square" alt="Latest Version"></a>
  <a href="https://travis-ci.com/crazy-max/docker-rtorrent-rutorrent"><img src="https://img.shields.io/travis/com/crazy-max/docker-rtorrent-rutorrent/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/rtorrent-rutorrent/"><img src="https://img.shields.io/docker/stars/crazymax/rtorrent-rutorrent.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/rtorrent-rutorrent/"><img src="https://img.shields.io/docker/pulls/crazymax/rtorrent-rutorrent.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/crazymax/rtorrent-rutorrent"><img src="https://quay.io/repository/crazymax/rtorrent-rutorrent/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.codacy.com/app/crazy-max/docker-rtorrent-rutorrent"><img src="https://img.shields.io/codacy/grade/6474c343fbe745579b1cb12c8d193647.svg?style=flat-square" alt="Code Quality"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EE33GDGPLZ4Q6"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [rTorrent](https://github.com/rakshasa/rtorrent) and [ruTorrent](https://github.com/Novik/ruTorrent) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

## Features

### Included

* Latest [rTorrent](https://github.com/rakshasa/rtorrent) / [libTorrent](https://github.com/rakshasa/libtorrent) release compiled from source
* Latest [ruTorrent](https://github.com/Novik/ruTorrent) release
* Name resolving enhancements with [c-ares](https://github.com/rakshasa/rtorrent/wiki/Performance-Tuning#rtrorrent-with-c-ares) for asynchronous DNS requests (including name resolves)
* Enhanced [rTorrent config](assets/tpls/.rtorrent.rc) and bootstraping with a [local config](assets/tpls/etc/.rtlocal.rc)
* Ability to remap user and group (UID/GID)
* WAN IP address automatically resolved for reporting to the tracker
* XMLRPC through nginx over SCGI socket (basic auth optional)
* WebDAV on completed downloads (basic auth optional)
* Ability to add a custom ruTorrent plugin / theme
* Allow to persist specific configuration for ruTorrent plugins
* ruTorrent [GeoIP2 plugin](https://github.com/Micdu70/geoip2-rutorrent)
* [mktorrent](https://github.com/Rudde/mktorrent) installed for ruTorrent create plugin

### From docker-compose

* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates

## Environment variables

### General

* `TZ` : The timezone assigned to the container (default: `UTC`)
* `PUID` : The user id (default: `1000`)
* `PGID` : The group id (default: `1000`)
* `WAN_IP` : Public IP address reported to the tracker (default auto resolved with `dig +short myip.opendns.com @resolver1.opendns.com`)
* `MEMORY_LIMIT` : PHP memory limit (default: `256M`)
* `UPLOAD_MAX_SIZE` : Upload max size (default: `16M`)
* `OPCACHE_MEM_SIZE` : PHP OpCache memory consumption (default: `128`)
* `REAL_IP_FROM` : Trusted addresses that are known to send correct replacement addresses (default `0.0.0.0/32`)
* `REAL_IP_HEADER` : Request header field whose value will be used to replace the client address (default `X-Forwarded-For`)
* `LOG_IP_VAR` : Use another variable to retrieve the remote IP address for access [log_format](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format) on Nginx. (default `remote_addr`)
* `XMLRPC_AUTHBASIC_STRING` : Message displayed during validation of XMLRPC Basic Auth (default: `rTorrent XMLRPC restricted access`)
* `RUTORRENT_AUTHBASIC_STRING` : Message displayed during validation of ruTorrent Basic Auth (default: `ruTorrent restricted access`)
* `WEBDAV_AUTHBASIC_STRING` : Message displayed during validation of WebDAV Basic Auth (default: `WebDAV restricted access`)

### rTorrent

* `RT_LOG_LEVEL` : rTorrent log level (default: `info`)
* `RT_LOG_EXECUTE` : Log executed commands to `/data/rtorrent/log/execute.log` (default: `false`)
* `RT_LOG_XMLRPC` : Log XMLRPC queries to `/data/rtorrent/log/xmlrpc.log` (default: `false`)

### ruTorrent

* `RU_REMOVE_CORE_PLUGINS` : Remove ruTorrent core plugins ; comma separated (default: `erasedata,httprpc`)
* `RU_HTTP_USER_AGENT` : ruTorrent HTTP user agent (default: `Mozilla/5.0 (Windows NT 6.0; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0`)
* `RU_HTTP_TIME_OUT` : ruTorrent HTTP timeout in seconds (default: `30`)
* `RU_HTTP_USE_GZIP` : Use HTTP Gzip compression (default: `true`)
* `RU_RPC_TIME_OUT` : ruTorrent RPC timeout in seconds (default: `5`)
* `RU_LOG_RPC_CALLS` : Log ruTorrent RPC calls (default: `false`)
* `RU_LOG_RPC_FAULTS` : Log ruTorrent RPC faults (default: `true`)
* `RU_PHP_USE_GZIP` : Use PHP Gzip compression (default: `false`)
* `RU_PHP_GZIP_LEVEL` : PHP Gzip compression level (default: `2`)
* `RU_SCHEDULE_RAND` : Rand for schedulers start, +0..X seconds (default: `10`)
* `RU_LOG_FILE` : ruTorrent log file path for errors messages (default: `/data/rutorrent/rutorrent.log`)
* `RU_DO_DIAGNOSTIC` : ruTorrent diagnostics like permission checking (default: `true`)
* `RU_SAVE_UPLOADED_TORRENTS` : Save torrents files added wia ruTorrent in `/data/rutorrent/share/torrents` (default: `true`)
* `RU_OVERWRITE_UPLOADED_TORRENTS` : Existing .torrent files will be overwritten (default: `false`)
* `RU_FORBID_USER_SETTINGS` : If true, allows for single user style configuration, even with webauth (default: `false`)
* `RU_LOCALE` : Set default locale for ruTorrent (default: `UTF8`)

## Volumes

* `/data` : rTorrent / ruTorrent config, downloads, session files, log, ...
* `/passwd` : Contains htpasswd files for basic auth

## Ports

* `6881` : DHT UDP port (`dht.port.set`)
* `8000` : XMLRPC port through nginx over SCGI socket
* `8080` : ruTorrent HTTP port
* `9000` : WebDAV port on completed downloads
* `50000` : Incoming connections (`network.port_range.set`)

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](examples/compose) in `/var/rtorrent-rutorrent/` on your host for example. Edit the compose file with your preferences and run the following command :

```bash
$ touch acme.json
$ chmod 600 acme.json
$ docker-compose up -d
$ docker-compose logs -f
```

### Command line

You can also use the following minimal command :

```bash
$ docker run -d --name rtorrent_rutorrent \
  --ulimit nproc=65535 \
  --ulimit nofile=32000:40000 \
  -p 6881:6881/udp \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 9000:9000 \
  -p 50000:50000 \
  -v $(pwd)/data:/data \
  -v $(pwd)/passwd:/passwd \
  crazymax/rtorrent-rutorrent:latest
```

## Notes

### XMLRPC through nginx

rTorrent 0.9.7+ has a built-in daemon mode disabling the user interface, so you can only control it via XMLRPC.<br />
Nginx will route XMLRPC requests to rtorrent through port `8000`. These requests can be secured with basic authentication through the `/passwd/rpc.htpasswd` file in which you will need to add a username with his password.<br />
See below to populate this file with a user / password.

### WebDAV

WebDAV allows you to retrieve your completed torrent files in `/data/rtorrent/downloads/completed` on port `9000`.<br />
Like XMLRPC, these requests can be secured with basic authentication through the `/passwd/webdav.htpasswd` file in which you will need to add a username with his password.<br />
See below to populate this file with a user / password.

### Populate .htpasswd files

For ruTorrent basic auth, XMLRPC through nginx and WebDAV on completed downloads, you can populate `.htpasswd` files with the following command :

```
docker run --rm -it crazymax/rtorrent-rutorrent:latest htpasswd -Bbn <username> <password> >> $(pwd)/passwd/webdav.htpasswd
```

Htpasswd files used :

* `rpc.htpasswd` : XMLRPC through nginx
* `rutorrent.htpasswd` : ruTorrent basic auth
* `webdav.htpasswd` : WebDAV on completed downloads

### Boostrap config `.rtlocal.rc`

When rTorrent is started the bootstrap config [/etc/.rtlocal.rc](assets/tpls/etc/.rtlocal.rc) is imported.<br />
This configuration cannot be changed unless you rebuild the image or overwrite these elements in your `.rtorrent.rc`.<br />
Here are the particular properties of this file :

* `system.daemon.set = true` : Launcher rTorrent as a daemon
* A config layout for the rTorrent's instance you can use in your `.rtorrent.rc` :
  * `cfg.basedir` : Home directory of rtorrent (`/data/rtorrent/`)
  * `cfg.download` : Download directory (`/data/rtorrent/downloads/`)
  * `cfg.download_complete` : Completed downloads (`/data/rtorrent/downloads/completed/`)
  * `cfg.download_temp` :  Downloads in progress (`/data/rtorrent/downloads/temp/`)
  * `cfg.logs` : Logs directory (`/data/rtorrent/log/`)
  * `cfg.session` : Session directory (`/data/rtorrent/.session/`)
  * `cfg.watch` : Watch directory for torrents (`/data/rtorrent/watch/`)
  * `cfg.rundir` : Runtime data of rtorrent (`/run/rtorrent/`)
* `d.data_path` : Config var to get the full path of data of a torrent (workaround for the possibly empty `d.base_path` attribute)
* `directory.default.set` : Default directory to save the downloaded torrents (`cfg.download_temp`)
* `session.path.set` : Default session directory (`cfg.session`)
* PID file to `/run/rtorrent/rtorrent.pid`
* `network.scgi.open_local` : SCGI local socket and make it group-writable and secure
* `network.port_range.set` : Listening port for incoming peer traffic (`50000-50000`)
* `dht.port.set` : UDP port to use for DHT (`6881`)
* `log.open_file` : Default logging to `/data/rtorrent/log/rtorrent.log`
  * Log level can be modified with the environment variable `RT_LOG_LEVEL`
  * `rpc_events` are logged be default
  * To log executed commands, add the environment variable `RT_LOG_EXECUTE`
  * To log XMLRPC queries, add the environment variable `RT_LOG_XMLRPC`

### Override or add a ruTorrent plugin/theme

You can add a plugin for ruTorrent in `/data/rutorrent/plugins/`. If you add a plugin that already exists in ruTorrent, it will be removed from ruTorrent core plugins and yours will be used.<br />
And you can also add a theme in `/data/rutorrent/themes/`. The same principle as for plugins will be used if you want to override one.

> ⚠️ Container has to be restarted to propagate changes

### Edit a ruTorrent plugin configuration

As you probably know, plugin configuration is not outsourced in ruTorrent. Loading the configuration of a plugin is done via a `conf.php` file placed at the root of the plugin folder.<br />
To solve this problem with Docker, a special folder has been created in `/data/rutorrent/plugins-conf` to allow you to configure plugins.<br />
For example to configure the `diskspace` plugin, you will need to create the `/data/rutorrent/plugins-conf/diskspace.php` file with your configuration :

```php
<?php

$diskUpdateInterval = 10;	// in seconds
$notifySpaceLimit = 512;	// in Mb
$partitionDirectory = null;	// if null, then we will check rtorrent download directory (or $topDirectory if rtorrent is unavailable)
				// otherwise, set this to the absolute path for checked partition. 
```

> ⚠️ Container has to be restarted to propagate changes

## Upgrade

To upgrade, pull the newer image and launch the container :

```bash
docker-compose pull
docker-compose up -d
```

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EE33GDGPLZ4Q6)

## License

MIT. See `LICENSE` for more details.
