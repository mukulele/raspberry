#!/bin/bash
# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi
### Start Script
apt update && apt install mosquitto-clients
export SCRIPT_DIR=$(pwd)
export SCRIPT_NAME=runMqtt.sh
wget -qO ${SCRIPT_DIR}/${SCRIPT_NAME} https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/${SCRIPT_NAME}
chmod +x ${SCRIPT_DIR}/${SCRIPT_NAME}

##### create service and timer units
# service unit is called from timer units with parameter
export NAME=monitor-runMqtt
cat >/etc/systemd/system/${NAME}@.service <<EOF
[Unit]
Description=${NAME}
[Service]
Type=oneshot
ExecStart=${SCRIPT_DIR}/${SCRIPT_NAME} %i
EOF

# timer per hour, per day and per 10 seconds
for i in "hour=*-*-* *:00:00" "day=*-*-* 00:00:00" "second=*:*:0/10"; do  
   FREQ=${i%=*}       # split bevor '='
   VAL=${i#*=}        # split after '='
   # write timer unit file
   cat >/etc/systemd/system/${NAME}-${FREQ}@.timer <<EOF
   [Unit]
   Description=${NAME}-${FREQ} timer
   [Timer]
   Unit=${NAME}@%i.service
   OnCalendar=${VAL}
   Persistent=true
   [Install]
   WantedBy=timers.target
   EOF
   
   # enable Timer
   systemctl enable --now ${NAME}-${FREQ}@${FREQ}.timer
done
