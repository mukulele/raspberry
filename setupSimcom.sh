#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

# deactivate ModemManager
for cmd in stop disable ; do 
    systemctl $cmd ModemManager.service
done

echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{qmi/raw_ip}=="*", ATTR{qmi/raw_ip}="Y"' >>  /etc/udev/rules.d/99-rawip.rules
udevadm control --reload-rules
udevadm trigger
lsub -t

# NetworkManager
# connection for 1nce
nmcli connection add type gsm ifname '*' con-name 'test' apn 'iot.1nce.net' \
connection.autoconnect no \
connection.autoconnect-retries 10 \
connection.lldp 0 \
ipv4.dns "8.8.8.8 8.8.4.4"\
ipv4.route-data "10.60.2.239/32 10.60.10.132/32 10.60.8.222/32"\
ipv6.method disabled \
gsm.mtu 1200 


