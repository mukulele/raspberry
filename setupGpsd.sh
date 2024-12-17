#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi
mkdir -p /$PWD/setup
mkdir -p /$PWD/tracks
echo 'gpxlogger --interval 5 --minmove 20 --output "/$PWD/tracks/$(date '+%F %H:%M:%S').gpx" --reconnect" >> /$PWD/setuo/gpsdlogger_start.sh
chmod 755 /$PWD/setup/gpxlogger_start.sh
apt-get -y install gpsd  gpsd-clients gpsd-tools

sudo cp /home/pi/gpsd/gpsd /etc/default/gpsd
sudo cp /home/pi/gpsd/gpsd.service /etc/systemd/system/gpsd.service
sudo cp /home/pi/gpsd/gpsd.socket /etc/systemd/system/gpsd.socket
#sudo cp /home/pi/gpsd/gps2udp.service /etc/systemd/system/gps2udp.service
sudo cp /home/pi/gpsd/gpxlogger.service /etc/systemd/system/gpxlogger.service
sudo systemctl enable gpsd.service gpsd.socket gpxlogger.service
