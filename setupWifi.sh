#!/bin/bash
# setup basic Wifi dor country DE
# Set Country for WiFi
# detect wireless adapter: if [ -n "$(find /sys/class/net -follow -maxdepth 2 -name wireless 2>/dev/null| cut -d / -f 5)" ] ; then echo Wifi ; fi
if [ -n "$(iw dev)" ] 
    then 
	iw reg set DE
	# add first line for WiFi if not already there
	file="/etc/wpa_supplicant/wpa_supplicant.conf"
	zn=$(sed -n '/country/=' $file) # ermittelt Zeilennummer mit country
	if [ -z $zn ]
		then
		      sed -i '1 i\country=DE' $file
	fi
    rfkill unblock wifi 2>/dev/null
fi

