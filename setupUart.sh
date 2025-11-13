ric#!/bin/bash
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

# if using usb modem
echo "disable ModemManager"
systemctl stop ModemManager
systemctl disable ModemManager

# Install ppp for Internet connection
echo "install ppp"
apt-get install ppp

# chat
# copy options to /etc/ppp
# copy gprs to /etc/ppp/peers
# routing 1nce-routes
# copy 1nce-routes to /etc/ppp/ip-up.d
# start with pppd call gprs
# or systemd enable pppd@service
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gprs  -P /etc/ppp/peers
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/options  -P /etc/ppp
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/1nce-routes  -P /etc/ppp/ip-up.d
chmod 755 /etc/ppp/ip-up.d/1nce-routes
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/ppp@service@.service  -P /etc/systemd/system
systemctl daemon-reload
systemctl enable pppd@gprs.service

wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/ppp-keep-alive.sh  -P /conf
chmod 755 /conf/ppp-keep-alive.sh
# Prüfen ob Cronjob schon existiert
CRON_CMD="0 * * * * /conf/ppp-keep-alive.sh >> /var/log/ppp-health.log 2>&1"
(crontab -l 2>/dev/null | grep -Fv "$CRON_CMD"; echo "$CRON_CMD") | crontab -

echo
read -p "Press ENTER key to reboot CTRL c to exit" ENTER
echo "Rebooting..."
reboot now



