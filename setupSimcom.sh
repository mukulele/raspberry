#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

# deactivate ModemManager
# for cmd in stop disable ; do 
#    systemctl $cmd ModemManager.service
# done

echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{qmi/raw_ip}=="*", ATTR{qmi/raw_ip}="Y"' >>  /etc/udev/rules.d/99-rawip.rules
udevadm control --reload-rules
udevadm trigger
lsub -t

# NetworkManager: connection for 1nce IOT SIM:
# apn 'iot.1nce.net'
# ipv4.addresses "10.238.250.1"
nmcli connection add type gsm ifname '*' con-name 'wwan' apn 'iot.1nce.net' \
connection.id 'wwan' \
connection.autoconnect yes \
connection.autoconnect-retries 10 \
connection.metered yes \
connection.wait-device-timeout 1000 \
connection.wait-activation-delay 1000 \
ipv4.method manual \
ipv4.addresses "10.238.250.1/30" `# depending on SIMCard` \
ipv4.dns "8.8.8.8 8.8.4.4"\
ipv4.route-data "10.60.0.0/16"\
ipv6.method disabled \
gsm.mtu 1200 \
/
nmcli -p connection up 'wwan' --wait 10

# Network Manager: dispatcher
# the script currently configures the firewall
# routing and ip address of dev wwan is managed with nmcli above
cd /$PWD/setup/
wget https://raw.githubusercontent.com/mukulele/master/80-wwan-online-offline.sh
cp ./80-wwan-online-offline.sh /etc/NetworkManager/dispatcher.d/80-wwan-online-offline.sh
chown root /etc/NetworkManager/dispatcher.d/80-wwan-online-offline.sh
chmod +x /etc/NetworkManager/dispatcher.d/80-wwan-online-offline.sh
systemctl restart NetworkManager



