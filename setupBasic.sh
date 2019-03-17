#!/bin/bash
# Set the new hostname below for quiet setup or leave it blank to be asked
hname=

# Timezone
timedatectl set-timezone Europe/Berlin

# config the language to german
sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
localectl set-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE
# add first line for wifi
sed -i '1 i\country=DE' /etc/wpa_supplicant/wpa_supplicant.conf

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

# Reboot
reboot
