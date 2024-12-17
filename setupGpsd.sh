#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi
mkdir -p /$PWD/setup
mkdir -p /$PWD/tracks

# gpsdlogger startup script
echo 'gpxlogger --interval 5 --minmove 20 --output "/$PWD/tracks/$(date '+%F %H:%M:%S').gpx" --reconnect" >> /$PWD/setuo/gpsdlogger_start.sh
chmod 755 /$PWD/setup/gpxlogger_start.sh
apt-get -y install gpsd  gpsd-clients gpsd-tools

# gpsd default config
cat <<'EOF' >> /etc/default/gpsd
# gpsd come with two way of starting up:
# 1) automatic start up on boot (START_DAEMON="true")
# 2) "manually" startup (START_DAEMON="false")
START_DAEMON="true"
GPSD_OPTIONS="-G -n -r" 
# -G global required for containers ?
# -n nowait
# -N run inforegroud usefull for debugging
# -b Broken-device-safety mode, otherwise known as read-only mode
# Devices gpsd should collect to at boot time.
DEVICES="/dev/ttyAMC0"
# Use USB hotplugging to add new USB devices automatically to the daemon
USBAUTO="true"
GPSD_SOCKET="/var/run/gpsd.sock"
EOF

# gpsd.service
cat <<'EOF' >> /etc/systemd/system/gpsd.service
[Unit]
Description=GPS (Global Positioning System) Daemon
Requires=gpsd.socket
# Needed with chrony SOCK refclock
After=chronyd.service
StartLimitIntervalSec=30
StartLimitBurst=2
#OnFailure=reset_modem.service

[Service]
Type=forking
EnvironmentFile=-/etc/default/gpsd
ExecStart=/usr/sbin/gpsd $GPSD_OPTIONS $OPTIONS $DEVICES
#Restart=on-failure

[Install]
WantedBy=multi-user.target
Also=gpsd.socket
EOF

# gpsd.socket
cat <<'EOF' >> /etc/systemd/system/gpsd.socket
[Unit]
Description=GPS (Global Positioning System) Daemon Sockets

[Socket]
ListenStream=/run/gpsd.sock
ListenStream=127.0.0.1:2947
# To allow gpsd remote access, start gpsd with the -G option and
# uncomment the next two lines:
#ListenStream=[::]:2947
#ListenStream=0.0.0.0:2947
SocketMode=0600
#BindIPv6Only=yes

[Install]
WantedBy=sockets.target
EOF

# gpxlogger.service
cat <<'EOF' >> /etc/systemd/system/gpxlogger.service
[Unit]
Description=GPS (Global Positioning System) Daemon
Requires=gpsd.service

[Service]
ExecStart=/$PWD/setup/gpxlogger_start.sh
Restart=always
RuntimeMaxSec=1d
RestartSec=10

[Install]
WantedBy=multi-user.target
Also=gpsd.service
EOF

sudo systemctl enable gpsd.service gpsd.socket gpxlogger.service
