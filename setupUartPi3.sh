#!/bin/bash
# deactivate serial-getty@ttyAMA0.service 
systemctl stop serial-getty@ttyAMA0.service
systemctl disable serial-getty@ttyAMA0.service
systemctl mask serial-getty@ttyAMA0.service
# aktivate UART and switch miniUart to BT Interface
# Since buster the overlay ist renamed but the old name is still linked
# I kept enable_uart=1, altough it's described as done inside the overlay.
# The line core_freq=250 is needed otherwise BT is not working - see documentation for details.
# https://www.raspberrypi.org/documentation/configuration/uart.md
# https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md
cat <<EOF >> /boot/config.txt
enable_uart=1
dtoverlay=miniuart-bt
core_freq=250
EOF
