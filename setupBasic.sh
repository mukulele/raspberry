#!/bin/bash
# Set the new hostname below for quiet setup or leave it blank to be asked
hname=
PACKAGE_LANG='en_US.UTF-8 de_DE.UTF-8'
# first load the latest software
apt -y update
apt -y full-upgrade

# Timezone
timedatectl set-timezone Europe/Berlin

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
# config the language to german
# localedef -f UTF-8 -i de_DE de_DE.UTF-8
# localectl set-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE
# alternativ
for lang in ${PACKAGE_LANG}; do sed -i -e "s/# $lang/$lang/" /etc/locale.gen; done
locale-gen
export LANG=de_DE.UTF-8 
export LANGUAGE=de:en
export LC_ALL=de_DE.UTF-8
# keyboard settings todo unsicher ?
localectl set-keymap de
# setupcon liefert derzeit eine (einmalige?) Fehlermeldung https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=903393
# das scheint aber ohne Auswirkung?
setupcon

# Hostname
oname=$(hostname)
if [ -z $hname ]
	then
		read -p "Hostname "$oname" ändern? Bitte den neuen Hostnamen eingeben, oder einfach enter:" hnameneu
		if [[ $hnameneu != "" ]]
			then
				hname=$hnameneu
		fi
fi
if [[ $hname != "" ]]
	then
	hostnamectl set-hostname $hname
        sed -i s/$oname/$hname/ /etc/hosts
	sed -i s/$oname/$hname/ /etc/ssh/*.pub
fi

# Password 
# echo "linuxpassword" | passwd --stdin linuxuser

# Reboot
# reboot
echo "Ein reboot ist empfohlen!"
