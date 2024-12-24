#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

sed -i "max_usb_current=1" /boot/firmware/config.txt

apt -y update
mkdir -p /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/99-rawip.rules -P /conf
install -m 644 /conf/99-rawip.rules /etc/udev/rules.d/99-rawip.rules #equi to echo Y > /sys/class/net/wwan0/qmi/raw_ip
udevadm control --reload-rules
udevadm trigger
echo "---------------------------"
lsusb | grep SIM
lsusb -t | grep wwan
dmesg -T | grep GSM # tail -5  # die letzten 5 Nachrichten
# driver errors nonzero urb status received: -71
# https://forums.quectel.com/t/ec25-wwan-nonzero-urb-status-received-71/4495/3
# > usb power unstable
# usb,a
nmcli general status
nmcli dev | grep cdc-wdm0

echo "---------------------------"

# NetworkManager
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/networking_guide/sec-configuring_ip_networking_with_nmcli#sec-Creating_and_Modifying_a_Connection_Profile_with_nmcli
# https://modemmanager.org/docs/modemmanager/ip-connectivity-setup-in-lte-modems
# connection for 1nce IOT SIM: 'iot.1nce.net'
PARAMS=(
connection.type gsm \
connection.interface-name "cdc-wdm0" \
connection.id "1nce" \
apn "iot.1nce.net" \
gsm.mtu 1200 \
ipv4.address 10.238.250.1/30 \
ipv4.gateway 10.238.250.2 \ #@todo
ipv4.routes "10.60.0.0/16 10.238.250.1" \
ipv4.method manual \
ipv4.dns "8.8.8.8 8.8.4.4" \
ipv4.routes "10.60.0.0/16 10.238.250.1" \
ipv6.method disabled
)

nmcli connection add "${PARAMS[@]}"

#nmcli connection modify 1nce +connection.autoconnect yes
#nmcli connection modify 1nce +connection.metered yes
#nmcli connection modify 1nce +ipv4.routes "10.60.0.0/16  10.238.250.1" # private adress space 1nce 
#nmcli connection modify 1nce +connection.autoconnect-retries 0 # forever
#nmcli connection modify 1nce +connection.wait-device-timeout 1000
#nmcli connection modify 1nce +connection.wait-activation-delay 1000
#nmcli connection save persistent 1nce

nmcli connection up 1nce ifname cdc-wdm0

#test
mmcli -L
mmcli -m $1

#start options
#mmcli -G DEBUG #maximum DEBUG level
#mmcli -G ERR   #min DEBUG level

# test
nmcli d
ifconfig wwan0

# Network Manager: dispatcher
# the script currently configures the firewall
# routing and ip address of dev wwan is managed with nmcli above
#wget https://raw.githubusercontent.com/mukulele/master/conf/80-wwan-online-offline.sh -P /conf
#install -m 755 /conf/80-wwan-online-offline.sh /etc/NetworkManager/dispatcher.d/80-wwan-online-offline.sh
#systemctl restart NetworkManager



