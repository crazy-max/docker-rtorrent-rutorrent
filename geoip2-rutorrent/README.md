## geoip2 plugin for ruTorrent

This repository vendors this plugin in `./geoip2-rutorrent` and builds it into the image from local source instead of fetching it during the Docker build.

![geoip2-plugin-for-ruTorrent](https://i.imgur.com/jCluJCe.png)

*A new geoip plugin working with GeoLite2 (MaxMind DB Files)*

### Informations

This plugin...

- is based on the original 'geoip' plugin.

- uses [GeoIP2-php](https://maxmind.github.io/GeoIP2-php/)'s geoip2.phar API (v2.9.0) by MaxMind, Inc.

- uses GeoLite2 data created by MaxMind, available from
<a href="http://www.maxmind.com">http://www.maxmind.com</a>.

### Requirements

To be able to use the plugin:

* Use ruTorrent **v4.0**
* PHP 'json' extension

To be able to display country/city:

* PHP >= 5.4.0
* PHP 'bcmath' extension
* PHP 'phar' extension

### Installation

Place all the plugin files in a directory called 'geoip2' in the rutorrent/plugins directory.

For standalone use outside this repository, clone the upstream plugin into the rutorrent/plugins directory:

`git clone https://github.com/Micdu70/geoip2-rutorrent.git geoip2`

> **Note:** It is important that the plugin directory is named 'geoip2' so that the supporting files are loaded correctly.

> **You need to disable or remove the original 'geoip' plugin to allow this one to work.**

### Update or change database

**UPDATE FROM DECEMBER 30, 2019: It now requires to sign up to be able to download GeoLite2 databases.**

GeoLite2 Free Downloadable Databases: https://dev.maxmind.com/geoip/geoip2/geolite2/#Downloads

Download MaxMind DB binary, gzipped `GeoLite2 Country` or `GeoLite2 City`, extract and find

* `GeoLite2-Country.mmdb` file (country info only)

-or-

* `GeoLite2-City.mmdb` file (country & city info)

and move it in the `database` geoip2 plugin directory.

> **Info:** If both `GeoLite2-Country.mmdb` and `GeoLite2-City.mmdb` are installed, `GeoLite2-City.mmdb` is used.
