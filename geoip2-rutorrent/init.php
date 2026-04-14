<?php

use GeoIp2\Database\Reader;

if($theSettings->isPluginRegistered("geoip"))
	$jResult .= "plugin.disable();";
else
{
	require_once( "sqlite.php" );

	eval( FileUtil::getPluginConf( $plugin["name"] ) );

	$retrieveCountry = ($retrieveCountry && (PHP_VERSION_ID >= 50400) && extension_loaded('bcmath') && extension_loaded('phar'));
	if($retrieveCountry)
	{
		require_once 'geoip2.phar';

		if($usePluginDatabase)
		{
			$cityDbFile = $rootPath.'/plugins/geoip2/database/GeoLite2-City.mmdb';
			$countryDbFile = $rootPath.'/plugins/geoip2/database/GeoLite2-Country.mmdb';
		}
		else
		{
			if(empty($cityDbFile))
				$cityDbFile = "/usr/share/GeoIP/GeoLite2-City.mmdb";
			if(empty($countryDbFile))
				$countryDbFile = "/usr/share/GeoIP/GeoLite2-Country.mmdb";
		}

		try{
			if(is_file($cityDbFile) && is_readable($cityDbFile))
				$reader = new Reader($cityDbFile);
			else
			{
				if(is_file($countryDbFile) && is_readable($countryDbFile))
					$reader = new Reader($countryDbFile);
				else
				{
					$retrieveCountry = false;
					$jResult .= "plugin.showError('theUILang.databaseNotFound');";
				}
			}
		} catch(Exception $e){$retrieveCountry = false; $jResult .= "plugin.showError('theUILang.databaseError');";}
	}
	$retrieveComments = ($retrieveComments && sqlite_exists());

	if( $retrieveCountry || $retrieveHost || $retrieveComments )
	{
		$theSettings->registerPlugin($plugin["name"], $pInfo["perms"]);
		if($retrieveCountry)
			$jResult .= "plugin.retrieveCountry = true;";
		if($retrieveComments)
			$jResult .= "plugin.retrieveComments = true;";
	}
	else
		$jResult .= "plugin.disable();";
}
