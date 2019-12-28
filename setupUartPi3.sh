#!/bin/bash
# deactivate serial-getty@ttyAMA0.service 
systemctl stop serial-getty@ttyAMA0.service
systemctl disable serial-getty@ttyAMA0.service
systemctl mask serial-getty@ttyAMA0.service
# aktivate UART and switch with BT Interface
# Since buster the overlay ist renamed but the old name is still linked
# I removed enable_uart=1 because this will be done by the overlay
# I removed the line core_freq=250 see documentation for details. I am not shure at this moment
# https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md
cat <<EOF >> /boot/config.txt
dtoverlay=miniuart-bt
EOF
