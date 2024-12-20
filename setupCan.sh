#!/bin/bash
# Enabling mcp2515 on SPI0.0 and SPI01 as can0 and can1

# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

# activate CAN
# @todo
mkdir -p /conf
cp /boot/firmware/config.txt /conf/config.txt.backup
cat <<EOF >> /boot/firmware/config.txt
dtparam=spi=on
# Enabling mcp2515 on SPI0.0 as can0
dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=23
# Enabling mcp2515 on SPI0.1 as can1
dtoverlay=mcp2515-can1,oscillator=16000000,interrupt=25
EOF

# write startup script
mkdir -p /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/startCan.sh -P /conf
install -m 755 /conf/startCan.sh /usr/local/bin/startCan.sh
sed -i '/fi/a/start_can.sh' /etc/rc.local
echo "-----------------------------"
echo "test with ifconfig | grep can"

