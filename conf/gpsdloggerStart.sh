#!/bin/bash
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi
gpxlogger --interval 5 --minmove 20 --output "/var/log/gpstracks-$(date '+%F %H:%M:%S').gpx" --reconnect
#gpxlogger --interval 5 --minmove 20 --output "/gpsdtracks/$(date '+%F %H:%M:%S').gpx" --reconnect
