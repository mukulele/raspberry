#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi
# NetworkManager connection
# no internet connection only local accesss
nmcli device wifi hotspot con-name hotspot ssid raspberry_ap band bg password clipperiv

# NetworkManager dispatcher
# the script currently enables the connection when eth is down and vice versa
cd /$PWD/setup/
wget https://raw.githubusercontent.com/mukulele/master/0-wifi-wired-exclusive.sh
cp ./70-wifi-wired-exclusive.sh /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh
chown root /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh
chmod +x /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh
systemctl restart NetworkManager

