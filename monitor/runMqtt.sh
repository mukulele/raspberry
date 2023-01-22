#!/bin/bash
#MQTT_SVR="servername|IPAdresse[ -p 1883]"
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
   echo "MQTT_SVR is empty, set MQTT_SVR first" 
   echo "or create a valid ${DIRECTORY}/$(basename $0 .sh).conf first"
   exit 1
fi

# check var units
if ! ls ${DIRECTORY}/*.var >/dev/null 2>&1 ; then 
  echo 'collector files not found locally - download the templates'
  wget -qN https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/{day,hour,second}.var
fi
# start for all or a given filename, if $1 is empty substitute with *  
for file in $(ls ${DIRECTORY:-.}/${1:-*}.var) ; do
  # file is executed, inside the loop all lines with white spaces or comments will be ignored 
  source ${file}
  for varname in $(cat ${file}|grep -vE '^#|^\s'|awk -F'=' '{print $1}') ;do
    $cmd -i ${MQTT_CID} -h ${MQTT_SVR} ${MQTT_ACCOUNT} -t ${MQTT_TOPIC}/${varname} -m "${!varname}" ${MQTT_ACCOUNT}
  done
done
