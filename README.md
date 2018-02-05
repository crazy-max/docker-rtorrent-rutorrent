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
* Enhanced [rTorrent config](assets/home/rtorrent/.rtorrent.rc) by default
* Name resolving enhancements with [c-ares](https://github.com/rakshasa/rtorrent/wiki/Performance-Tuning#rtrorrent-with-c-ares) for asynchronous DNS requests (including name resolves)
* Ability to remap user and group (UID/GID)
* WAN IP address automatically resolved for reporting to the tracker

## Environment variables

* `TZ` : The timezone assigned to the container (default to `UTC`)
* `UID` : The user id (default to `1000`)
* `GID` : The group id (default to `1000`)
* `WAN_IP` : Public IP address reported to the tracker (default auto resolved with `dig +short myip.opendns.com @resolver1.opendns.com`)

## Volumes

* `/home/rtorrent` : rTorrent config, downloads, session files, log, ...

## Ports

* `5000` : SCGI port (`scgi_port`)
* `6881` : DHT UDP port (`dht_port`)
* `50000` : Incoming connections (`port_range`)

## Usage

Docker compose is the recommended way to run this image. You can use the following [docker compose template](docker-compose.yml), then run the container :

```bash
$ docker-compose up -d
```

Or use the following command:

```bash
$ docker run -d --name rtorrent -it \
  --ulimit nproc=65535 nofile=32000:40000 \
  -p 5000:5000 \
  -p 6881:6881/udp \
  -p 50000:50000 \
  -p 50000:50000/udp \
  -e TZ="Europe/Paris" \
  -e UID=1000 \
  -e GID=1000 \
  -v $(pwd)/data:/home/rtorrent \
  crazymax/rtorrent:latest
```

## How can i help ?

We welcome all kinds of contributions :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
Any funds donated will be used to help further development on this project! :gift_heart:

[![Donate Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EE33GDGPLZ4Q6)

## License

MIT. See `LICENSE` for more details.
