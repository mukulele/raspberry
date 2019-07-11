#!/bin/bash
# Set the new hostname below for quiet setup or leave it blank to be asked
hname=

# first load the latest software
apt-get -y update
apt-get -y upgrade

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
localedef -f UTF-8 -i de_DE de_DE.UTF-8
# alternativ
#sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
#locale-gen
localectl set-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE
localectl set-keymap de
# setupcon liefert derzeit eine (einmalige?) Fehlermeldung https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=903393
# das scheint aber ohne Auswirkung?
setupcon

# Hostname 
if [ -z $hname ]
	then
		read -p "Hostname "$(hostname)" ändern? Bitte den neuen Hostnamen eingeben, oder einfach enter:" hnameneu
		if [[ $hnameneu != "" ]]
			then
				hname=$hnameneu
		fi
fi
if [[ $hname != "" ]]
	then
	hostnamectl set-hostname $hname
        sed -i s/raspberrypi/$hname/ /etc/hosts
	sed -i s/raspberrypi/$hname/ /etc/ssh/*.pub
fi

# Password 
# echo "linuxpassword" | passwd --stdin linuxuser

# Reboot
# reboot
echo "Ein reboot ist empfohlen!"
