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

echo "# log2ram"
wget https://github.com/azlux/log2ram/archive/master.tar.gz -O log2ram.tar.gz
tar xf log2ram.tar.gz
cd /log2ram-master
./install.sh
cd ~
rm log2ram.tar.gz

echo "# journalctl nach 30 Tagen löschen"
journalctl --rotate --vacuum-time=30d

echo "# RPI Monitor"
apt-get -y install sysstat

apt autoremove

echo "# Network Manager"
rm /etc/NetworkManager/NetworkManager.conf
cat <<EOF >> /etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no

[logging]
level=TRACE
domains=ALL
EOF
mkdir -p /setup
cp /etc/NetworkManager/NetworkManager.conf /setup/NetworkManager.conf
chown root /etc/NetworkManager/NetworkManager.conf

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

#Reboot
echo " "
echo "Reboot to apply change"
