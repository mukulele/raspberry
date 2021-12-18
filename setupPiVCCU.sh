#!/bin/sh
# Setup Components of piVCCU for raspberrymatic Docker Container 
# https://github.com/jens-maus/RaspberryMatic/wiki/Installation-Docker-OCI
# This Script have to execute in root context
# https://www.linuxjournal.com/content/automatically-re-start-script-root-0
# The inclusion of "bash" in the sudo command is to avoid problems if the script does not have its execute bit set. 
# The "exit $?" causes the shell to exit with the status from the script instance that sudo runs.

if [[ $UID -ne 0 ]]; then
    echo 'Script will be restartet with sudo'
    sudo -p 'Restarting as root, password: ' bash $0 "$@"
    exit $?
fi
# add sources list for pivccu repository
apt install wget ca-certificates gpg
wget -qO - https://www.pivccu.de/piVCCU/public.key | gpg --dearmor > /usr/share/keyrings/pivccude-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/pivccude-keyring.gpg] https://www.pivccu.de/piVCCU stable main" >/etc/apt/sources.list.d/pivccu.list
# install pivccu modules
apt update
apt install build-essential bison flex libssl-dev
apt install pivccu-modules-dkms
apt install pivccu-modules-raspberrypi
# activate kernel driver for pivccu
echo eq3_char_loop >/etc/modules-load.d/eq3_char_loop.conf
service pivccu-dkms start
modprobe eq3_char_loop

echo "Important! reboot is needed. copy & paste the following line"
echo "sudo reboot"

exit

cat <<EOT >>./docker/docker-compose.yml
version: "3.8"
services:
  raspberrymatic:
    image: ghcr.io/jens-maus/raspberrymatic:latest
    container_name: ccu
    hostname: homematic-raspi
    privileged: true
    restart: unless-stopped
    stop_grace_period: 30s
    volumes:
      - ccu_data:/usr/local:rw
      - /lib/modules:/lib/modules:ro
      - /run/udev/control:/run/udev/control
    ports:
      - "8080:80"
      - "2001:2001"
      - "2010:2010"
      - "9292:9292"
      - "8181:8181"
volumes:
  ccu_data:
EOT
