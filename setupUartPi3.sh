#!/bin/bash
# deactivate serial-getty@ttyAMA0.service 
systemctl stop serial-getty@ttyAMA0.service
systemctl disable serial-getty@ttyAMA0.service
systemctl mask serial-getty@ttyAMA0.service
# aktivate UART and switch with BT Interface
cat <<EOF >> /boot/config.txt
enable_uart=1
dtoverlay=pi3-miniuart-bt
core_freq=250
EOF
