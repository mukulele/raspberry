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

# switch miniUart to BT Interface for Pi Model 3, 4, Zero W and Zero WH
model=($(tr -d '\0' < /sys/firmware/devicetree/base/model))
if (( ${model[2]} >= 3 )) || ( [[ ${model[2]} == "Zero" ]] && [[ ${model[3]:0:1} == "W" ]] ); then
   cat <<EOF >> /boot/config.txt
dtoverlay=miniuart-bt
core_freq=250
EOF
echo 'and BT Module and Wifi will still working'
fi

# Install ppp for Internet connection
apt-get update
apt-get install -y ppp
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/ppp-creator.sh -P /conf
chmod +x /conf/ppp-creator.sh
# ./ppp-creator.sh INTERNET ttyS0` # Rpi3 > ttyS0 , others ttyAMA0 # INTERNET is APN, check your cellular
#4. Run `sudo pppd call gprs`
#5. run `ifconfig ppp0` at terminal window to see following outputs and see your ip<br/>
#  ```
#  ppp0      Link encap:Point-to-Point Protocol
#            inet addr:XX.XX.XXX.XXX  P-t-P:XX.XX.XX.XX  Mask:255.255.255.255
#            UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1500  Metric:1
#            RX packets:38 errors:0 dropped:0 overruns:0 frame:0
#            TX packets:39 errors:0 dropped:0 overruns:0 carrier:0
#            collisions:0 txqueuelen:3
#            RX bytes:3065 (2.9 KiB)  TX bytes:2657 (2.5 KiB)
#
#  ```

