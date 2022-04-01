#!/bin/bash
# run this Script as root
is_user_root () { [ "$(id -u)" -eq 0 ]; }
if ! is_user_root ; then
   exec sudo bash "$0" "$@"
fi

# Set the new hostname below for quiet setup or leave it blank to be asked
hname=
PACKAGE_LANG=(en_US.UTF-8 de_DE.UTF-8) # the first is fallback in LANGUAGE, the last is set to default
TZ='Europe/Berlin'
# first load the latest software
apt -y update
apt -y full-upgrade

# Timezone
timedatectl set-timezone $TZ

# config the default language, raspi-config is this doing in a similar way
for lang in ${PACKAGE_LANG[*]}; do sed -i -e "s/# $lang/$lang/" /etc/locale.gen; done 
dpkg-reconfigure -f noninteractive locales     # ? locale-gen
#####
# localectl set-locale LANG=${PACKAGE_LANG[-1]} LANGUAGE=${PACKAGE_LANG[-1]:0:2}:${PACKAGE_LANG[0]:0:2}
# update-locale         
#####
update-locale LANG=${PACKAGE_LANG[-1]} LANGUAGE=${PACKAGE_LANG[-1]:0:2}:${PACKAGE_LANG[0]:0:2}

# keyboard settings
localectl set-keymap ${PACKAGE_LANG[-1]:0:2}
# Code from raspi-config 
setupcon -k --force <> /dev/tty1 >&0 2>&1

# Hostname
oname=$(hostname)
if [ -z $hname ] ; then
		read -p "Hostname "$oname" ändern? Bitte den neuen Hostnamen eingeben, oder einfach enter:" hnameneu
		if [[ $hnameneu != "" ]] ; then
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
