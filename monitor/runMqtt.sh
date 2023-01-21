#!/bin/bash
MQTT_SVR="192.168.56.187"
TOPIC="monitor/system"
if ! cmd=$(which mosquitto_pub) ; then echo 'ERROR install mosquitto-clients'; fi
DIRECTORY=$(cd `dirname $0` && pwd)
if ! ls ${DIRECTORY}/*.var; then echo wget -qN https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/{day,hour,second}.var ; fi
for file in $(ls ${DIRECTORY}/*.var) ; do
  source ${file}
  for varname in $(cat ${file}|grep -vE '^#'|awk -F'=' '{print $1}') ;do
    echo "$cmd -i $(hostname) -h ${MQTT_SVR} -t ${TOPIC}/${varname} -m ${!varname} -q 1"
  done
done

