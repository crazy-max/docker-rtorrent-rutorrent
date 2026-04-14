#!/bin/bash

# Makes CSS file with links to flag pictures
# Quick and dirty, scans only local "flags" directory
#
# cd geoip2 && ./make_css.sh

if [ -f geoip2.css ]; then
    cp geoip2.css geoip2.css.bak
    echo "Copied geoip2.css  to  geoip2.css.bak"
fi
# Truncate file
> geoip2.css

if [ ! -d flags ]; then
	echo "Directory flags does not exist"
	exit 1
fi

echo ".geoip {background-repeat: no-repeat; background-position: center center; width: 22px; }" >> geoip2.css

for fl in `ls -1 flags/*[Gg][Ii][Ff]`
do
    # Remove prefix and suffix, we need only country code
    cnt=${fl/\/*\//}
    cnt=${cnt/.*/}
    cnt=${cnt#*/}
    echo ".geoip_flag_"$cnt" {background-image: url( \""$fl"\" ); }" >> geoip2.css
done
