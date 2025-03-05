#!/bin/bash
# The line core_freq=250 is needed otherwise BT is not working - see documentation for details.
# https://www.raspberrypi.org/documentation/configuration/uart.md
# https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

# deactivate serial-getty@ttyAMA0.service
for cmd in stop disable mask ; do 
    systemctl $cmd serial-getty@ttyAMA0.service
done
# aktivate UART 
raspi-config nonint do_serial_hw 0 # enable serial port
echo "after reboot: serial UART/AMA0 is working for additional modules"
raspi-config nonint do_serial_cons 1 # disable serial console
# disable hciuart
systemctl disable hciuart
# switch miniUart to BT Interface for Pi Model 3, 4, Zero W and Zero WH
model=($(tr -d '\0' < /sys/firmware/devicetree/base/model))
if (( ${model[2]} >= 3 )) || ( [[ ${model[2]} == "Zero" ]] && [[ ${model[3]:0:1} == "W" ]] ); then
   cat <<EOF >> /boot/config.txt
dtoverlay=miniuart-bt
core_freq=250
EOF
echo 'and BT Module and Wifi will still working'
fi

echo "disable ModemManager"
systemctl stop ModemManager
systemctl disable ModemManager

# Install ppp for Internet connection
echo "install ppp"
apt-get install ppp

#@todo
#routing in /etc/ppp/ip.up
#ip route del default ppp0
#ip route add 10.0.0.0/8 dev ppp0
#ip route del default dev ppp0
#ip route del 10.64.64.64
#check resolv.conf in /etc/ppp


echo "creating directories"
mkdir -p /etc/chatscripts
mkdir -p /etc/ppp/peers

echo "downloading ppp config"
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/provider  -P /etc/ppp/peers
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/provider-full  -P /etc/ppp/peers
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/chat-connect  -P /etc/chatscripts
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/chat-connect-full  -P /etc/chatscripts
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/chat-disconnect  -P /etc/chatscripts
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/ppp-keep-alive.sh  -P /conf

crontab <<EOF
@reboot pon
*/15 * * * * /conf/ppp-keep-alive.sh
EOF

read -p "Press ENTER key to reboot CTRL c to exit" ENTER
echo "Rebooting..."
reboot now



