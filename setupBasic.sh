#!/bin/bash
# Set the new hostname below for quiet setup or leave it blank to be asked
hname=

# Timezone
timedatectl set-timezone Europe/Berlin

# Set Country for WiFi
iw reg set De
# add first line for WiFi if not already there
file= /etc/wpa_supplicant/wpa_supplicant.conf
zn=$(sed -n '/country/=' $file) # ermittelt Zeilenummer mit country
if [ -z $zn ]
        then
              sed -i '1 i\country=DE' $file
fi

# config the language to german
localedef -f UTF-8 -i de_DE de_DE.UTF-8
localectl set-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE
localectl set-keymap de
setupcon

# Hostname 
if [ -z $hname ]
	then
		hname=$(hostname)
		read -p "Hostname "$hname" ändern? Bitte den neuen Hostnamen eingeben:" hnameneu
		if [ -n $hnameneu ]
			then
				hname=$hnameneu
		fi
fi
hostnamectl set-hostname $hname
apt-get -y update
apt-get -y upgrade

# Password 
# echo "linuxpassword" | passwd --stdin linuxuser

# Reboot
# reboot
