#!/bin/bash
#MQTT_SVR="192.168.56.187"
MQTT_TOPIC="monitor/system"
#MQTT_ACCOUNT="-u user -P password"
MQTT_CID=${HOSTNAME}

DIRECTORY=$(cd `dirname $0` && pwd)
if conf=$(ls ${DIRECTORY}/$(basename $0 .sh).conf 2>/dev/null) ; then 
  #echo "config $conf vorhanden"
  source ${conf}
fi
# check prerequisits and set cmd
if ! cmd=$(which mosquitto_pub) ; then 
  echo 'ERROR install mosquitto-clients first'
  exit 1
fi
if [ "${MQTT_SVR}" == "" ] ; then
   echo "MQTT_SVR is empty, please create a valid ${DIRECTORY}/$(basename $0 .sh).conf first"
   exit 1
fi

# check var units
if ! ls ${DIRECTORY}/*.var >/dev/null; then 
  wget -qN https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/{day,hour,second}.var
fi
# start for all or a given filename, if $1 is empty substitute with *  
for file in $(ls ${DIRECTORY:-.}/${1:-*}.var) ; do
  source ${file}
  for varname in $(cat ${file}|grep -vE '^#'|awk -F'=' '{print $1}') ;do
    $cmd -i ${MQTT_CID} -h ${MQTT_SVR} ${MQTT_ACCOUNT} -t ${MQTT_TOPIC}/${varname} -m "${!varname}" ${MQTT_ACCOUNT}
  done
done
