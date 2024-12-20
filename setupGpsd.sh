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
wget https://raw.githubusercontent.com/mukulele/raspberry/master/conf/gpsd, gpsd.service, gpsd.socket, gpxlogger.service, gpsdloggerStart.sh \
-P /etc/default
mkdir -p /tracks

# gpsdlogger startup script
# wget ...gpxlogger_start.sh
chmod +x /setup/gpxlogger_start.sh
apt-get -y install gpsd  gpsd-clients gpsd-tools

# gpsd default config
# wget
# rm /etc/default/gpsd
# cp


# gpsd.service
# wget
# rm
# install /etc/systemd/system/gpsd.service


# gpsd.socket
# wget cat <<'EOF' >> /etc/systemd/system/gpsd.socket
# rm
# cp

# gpxlogger.service
# wget
# rm
# cp /etc/systemd/system/gpxlogger.service

sudo systemctl enable gpsd.service gpsd.socket gpxlogger.service
