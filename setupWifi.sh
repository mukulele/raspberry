#!/bin/bash
# setup basic Wifi dor country DE
# Set Country for WiFi
if [ -n "$(iw dev)" ] 
    then 
	iw reg set DE
	# add first line for WiFi if not already there
	file="/etc/wpa_supplicant/wpa_supplicant.conf"
	zn=$(sed -n '/country/=' $file) # ermittelt Zeilenummer mit country
	if [ -z $zn ]
		then
		      sed -i '1 i\country=DE' $file
	fi
fi

rfkill unblock wifi
