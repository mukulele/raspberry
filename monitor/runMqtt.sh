#!/bin/bash
MQTT_SVR="192.168.56.187"
TOPIC="monitor/system"
#ACCOUNT="-u user -P password"

DIRECTORY=$(cd `dirname $0` && pwd)
if conf=$(ls ${DIRECTORY}/$(basename $0 .sh).conf 2>/dev/null) ; then 
  #echo "config $conf vorhanden"
  source ${conf}
fi

if ! cmd=$(which mosquitto_pub) ; then 
  echo 'ERROR install mosquitto-clients first'
  exit 1
fi

if ! ls ${DIRECTORY}/*.var >/dev/null; then 
  wget -qN https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/{day,hour,second}.var
fi

if [ $# -eq 0 ] ; then mask=*; else mask=$1 ; fi
files="$(ls ${DIRECTORY}/${mask}.var)"
for file in ${files} ; do
  source ${file}
  for varname in $(cat ${file}|grep -vE '^#'|awk -F'=' '{print $1}') ;do
    $cmd -i $(hostname) -h ${MQTT_SVR} -t ${TOPIC}/${varname} -m "${!varname}" ${ACCOUNT}
  done
done
