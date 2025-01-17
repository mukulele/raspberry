#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
# @todo chmod +x required
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

### Start Script
# first load the latest software
apt -y update
apt -y full-upgrade

echo "# Midnight Commander"
apt-get -y install mc

echo "# journalctl nach 30 Tagen löschen"
journalctl --rotate --vacuum-time=30d

echo "# RPI Monitor"
apt-get -y install sysstat

apt autoremove
# @todo enable ifup down und keyfiles... notwendig?
echo "# Network Manager"
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/NetworkManager.conf  -P /conf
install -m 644 /conf/NetworkManager.conf /etc/NetworkManager/conf.d --backup


#watchdog
#echo "Enabling watchdog?"
#read -p "Continue (y/n)?" CONT
#if [ "$CONT" = "y" ]; then
#modprobe bcm2835_wdt
#apt-get install watchdog
# cp /$PWD/setup/watchdog.conf etc/init.d/watchdog @todo
#/etc/init.d/watchdog start
#else
#  echo "skipped";
#fi

echo "# log2ram"
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bookworm main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
apt update
apt install log2ram
echo "REBOOT before installing anything else"
