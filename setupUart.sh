#!/bin/bash
# Since buster the overlay ist renamed but the old name is still linked
# I kept enable_uart=1, altough it's described as done inside the overlay.
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
echo 'enable_uart=1' >> /boot/config.txt
echo "after reboot: serial UART/AMA0 is working for additional modules"

# switch miniUart to BT Interface for Pi Model 3, 4, Zero W and Zero WH
model=($(tr -d '\0' < /sys/firmware/devicetree/base/model))
if (( ${model[2]} >= 3 )) || ( [[ ${model[2]} == "Zero" ]] && [[ ${model[3]:0:1} == "W" ]] ); then
   cat <<EOF >> /boot/config.txt
dtoverlay=miniuart-bt
core_freq=250
EOF
echo 'and BT Module and Wifi will still working'
fi
