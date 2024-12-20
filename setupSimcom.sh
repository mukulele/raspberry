#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

mkdir -p /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/99-rawip.rules -P /conf
install -m 644 /conf/99-rawip.rules /etc/udev/rules.d/99-rawip.rules --backup
udevadm control --reload-rules
udevadm trigger
echo "---------------------------"
lsusb | grep SIM
lsusb -t | grep wwan
echo "---------------------------"

# NetworkManager: connection for 1nce IOT SIM:
# apn 'iot.1nce.net'
# ipv4.addresses "10.238.250.1"
nmcli connection add type gsm ifname '*' con-name 'wwan' apn 'iot.1nce.net'
nmcli connection modify wwan +ipv4.routes 10.60.0.0/16
nmcli connection modify wwan +ipv4.method "manual"
nmcli connection modify wwan +connection.autoconnect yes
nmcli connection modify wwan +connection.metered yes
nmcli connection modify wwan +ipv4.addresses 10.238.250.1/30 # static ip for SIM
nmcli connection modify wwan +ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection modify wwan +ipv4.routes 10.60.0.0/16 # private adress space 1nce
nmcli connection modify wwan +ipv6.method "disabled"
nmcli connection modify wwan +gsm.mtu 1200
nmcli connection modify wwan +connection.autoconnect-retries 0 # forever
nmcli connection modify wwan +connection.wait-device-timeout 1000
nmcli connection modify wwan +connection.wait-activation-delay 1000
nmcli connection save persistent wwan

nmcli -p connection up 'wwan'

# test
nmcli d
ifconfig wwan0

# Network Manager: dispatcher
# the script currently configures the firewall
# routing and ip address of dev wwan is managed with nmcli above
#wget https://raw.githubusercontent.com/mukulele/master/conf/80-wwan-online-offline.sh -P /conf
#install -m 755 /conf/80-wwan-online-offline.sh /etc/NetworkManager/dispatcher.d/80-wwan-online-offline.sh
#systemctl restart NetworkManager



