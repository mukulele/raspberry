#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
systemctl -q is-active gpsd && {
    echo "ERROR: gpsd service is still running. Please run \"sudo systemctl stop gpsd\" to stop it."
    exit 1
}

if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

apt update
apt-get -y install gpsd  gpsd-clients gpsd-tools
mkdir -p /etc/default/gpsd
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gpsd -P /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gpsd.service -P /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gpsd.socket -P /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gpxlogger.service -P /conf
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gpsdloggerStart.sh -P /conf
install -m 644 /conf/gpsd /etc/default/gpsd --backup
install -m 644 /conf/gpsd.service /etc/systemd/system/gpsd.service --backup
install -m 644 /conf/gpsd.socket /etc/systemd/system/gpsd.socket --backup
install -m 644 /conf/gpxlogger.service /etc/systemd/system/gpxlogger.service --backup
install -m 755 /conf/gpsdloggerStart.sh /usr/local/bin/gpsdloggerStart.sh
mkdir -p /gpsdtracks
systemctl enable gpsd.service gpsd.socket gpxlogger.service
echo"-------------------"
echo "test with gpsmon"