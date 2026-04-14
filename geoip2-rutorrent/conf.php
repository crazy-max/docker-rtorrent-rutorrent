<?php
	// configuration parameters

	$retrieveCountry = true;
	$retrieveHost = true;
	$retrieveComments = true;

	$usePluginDatabase = true; // search and use GeoLite2 database in "database" plugin' directory

	// If $usePluginDatabase is set to false:
	$cityDbFile = "";	// empty = "/usr/share/GeoIP/GeoLite2-City.mmdb"
	$countryDbFile = "";	// empty = "/usr/share/GeoIP/GeoLite2-Country.mmdb"

	// For retrieve hosts

	$dnsResolver = '1.1.1.1';	// use gethostbyaddr, if null
	$dnsResolverTimeout = 1;	// timeout in seconds
