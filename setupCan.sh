#!/bin/bash
# Enabling mcp2515 on SPI0.0 and SPI01 as can0 and can1

# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

# activate CAN 
cat <<EOF >> /boot/firmware/config.txt
dtoverlay=mcp2515-can1,oscillator=16000000,interrupt=25
dtoverlay=mcp2515-can1,oscillator=16000000,interrupt=25
EOF
# @TODOchmod +x
# write startup script
mkdir -p /$PWD/setup
cat <<EOF >> /$PWD/setup/startCan.sh
# bitrate 250000 VE.Can NMEA2000
# bitrate 500000 CANbus BMS
ifconfig can0 txqueuelen 65536
ip link set can0 up type can bitrate 250000
ip link set can1 up type can bitrate 500000
sudo ifconfig can0 txqueuelen 65536
sudo ifconfig can1 txqueuelen 65536
EOF
chmod +x /$PWD/setup/start_can.sh
sed -i '/fi/a/$PWD/setup/start_can.sh' /etc/rc.local

