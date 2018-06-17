<p align="center"><a href="https://github.com/crazy-max/docker-rtorrent" target="_blank"><img height="128"src="https://raw.githubusercontent.com/crazy-max/docker-rtorrent/master/.res/docker-rtorrent.jpg"></a></p>

<p align="center">
  <a href="https://microbadger.com/images/crazymax/rtorrent"><img src="https://images.microbadger.com/badges/version/crazymax/rtorrent.svg?style=flat-square" alt="Version"></a>
  <a href="https://travis-ci.org/crazy-max/docker-rtorrent"><img src="https://img.shields.io/travis/crazy-max/docker-rtorrent/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/rtorrent/"><img src="https://img.shields.io/docker/stars/crazymax/rtorrent.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/rtorrent/"><img src="https://img.shields.io/docker/pulls/crazymax/rtorrent.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/crazymax/rtorrent"><img src="https://quay.io/repository/crazymax/rtorrent/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EE33GDGPLZ4Q6"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [rTorrent](https://github.com/rakshasa/rtorrent) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

## Features

* Latest stable [rTorrent](https://github.com/rakshasa/rtorrent) / [libTorrent](https://github.com/rakshasa/libtorrent) release compiled from source
* Enhanced [rTorrent config](assets/var/rtorrent/.rtorrent.rc) by default
* Name resolving enhancements with [c-ares](https://github.com/rakshasa/rtorrent/wiki/Performance-Tuning#rtrorrent-with-c-ares) for asynchronous DNS requests (including name resolves)
* Ability to remap user and group (UID/GID)
* WAN IP address automatically resolved for reporting to the tracker
* XMLRPC through nginx over SCGI socket with basic auth
* WebDAV on completed downloads with basic auth

## Environment variables

* `TZ` : The timezone assigned to the container (default to `UTC`)
* `PUID` : The user id (default to `1000`)
* `PGID` : The group id (default to `1000`)
* `WAN_IP` : Public IP address reported to the tracker (default auto resolved with `dig +short myip.opendns.com @resolver1.opendns.com`)

## Volumes

* `/var/rtorrent` : rTorrent config, downloads, session files, log, ...

## Ports

* `6881` : DHT UDP port (`dht.port.set`)
* `8000` : XMLRPC port through nginx over SCGI socket with basic auth
* `9000` : WebDAV port with basic auth on completed downloads
* `50000` : Incoming connections (`network.port_range.set`)

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](examples/compose) in `/var/rtorrent/` on your host for example. Edit the compose file with your preferences and run the following command :

```bash
$ docker-compose up -d
```

### Command line

You can also use the following command :

```bash
$ docker run -d --name rtorrent \
  --ulimit nproc=65535 nofile=32000:40000 \
  -p 6881:6881/udp \
  -p 8000:8000 \
  -p 9000:9000 \
  -p 50000:50000 \
  -e TZ="Europe/Paris" \
  -e PUID=1000 \
  -e PGID=1000 \
  -v $(pwd)/data:/var/rtorrent \
  crazymax/rtorrent:latest
```

## Notes

### SCGI unix domain socket

rTorrent socket is available in `/var/rtorrent/run/scgi.socket` if you want to use it with your favorite client (ruTorrent, Flood).

### XMLRPC through nginx

rTorrent 0.9.7+ has a built-in daemon mode disabling the user interface, so you can only control it via XMLRPC.<br />
Nginx will route XMLRPC requests to rtorrent through port `8000`. These requests are secured with basic authentication through the `/var/rtorrent/rpc.htpasswd` file in which you will need to add a username with his password. You can use the following command to populate this file :

```
docker run --rm -it crazymax/rtorrent:latest htpasswd -Bbn <username> <password> > $(pwd)/data/rpc.htpasswd
```

### WebDAV

WebDAV allows you to retrieve your completed torrent files in `/var/rtorrent/downloads/completed` on port `9000`.<br />
Like XMLRPC, these requests are secured with basic authentication through the `/var/rtorrent/webdav.htpasswd` file in which you will need to add a username with his password. You can use the following command to populate this file :

```
docker run --rm -it crazymax/rtorrent:latest htpasswd -Bbn <username> <password> > $(pwd)/data/webdav.htpasswd
```

## Upgrade

To upgrade, pull the newer image and launch the container :

```bash
docker-compose pull
docker-compose up -d
```

## How can i help ?

All kinds of contributions are welcomed :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EE33GDGPLZ4Q6)

## License

MIT. See `LICENSE` for more details.
