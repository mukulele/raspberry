#!/bin/sh
# Setup Components of piVCCU for raspberrymatic Docker Container 
# https://github.com/jens-maus/RaspberryMatic/wiki/Installation-Docker-OCI

sudo apt install wget ca-certificates gpg

sudo sh -c 'wget -qO - https://www.pivccu.de/piVCCU/public.key | gpg --dearmor > /usr/share/keyrings/pivccude-keyring.gpg'
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/pivccude-keyring.gpg] https://www.pivccu.de/piVCCU stable main" >/etc/apt/sources.list.d/pivccu.list'

sudo apt update
sudo apt install build-essential bison flex libssl-dev
sudo apt install pivccu-modules-dkms
sudo apt install pivccu-modules-raspberrypi

sudo sh -c 'echo eq3_char_loop >/etc/modules-load.d/eq3_char_loop.conf'
sudo service pivccu-dkms start
sudo modprobe eq3_char_loop

echo "Neustart erforderlich"
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
