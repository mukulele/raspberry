#!/bin/sh
# patch .env File with real data

option='-i' # for replacements inline
option=''   # for test only sed result
sed $option s/SONOS2MQTT_DEVICE=.*$/SONOS2MQTT_DEVICE=$(host -4 -W1 -t A  SonosZP | awk '/has address/ { print $NF; exit }')/ .env
sed $option "s/SONOS2MQTT_MQTT=.*$/SONOS2MQTT_MQTT=mqtt:\/\/$(hostname):1883/" .env
sed $option "s/SONOS_LISTENER_HOST=.*$/SONOS_LISTENER_HOST=$(hostname)/" .env
sed $option "s/CONBEE=.*$/CONBEE=$(ls /dev/serial/by-id/|grep ConBee)/" .env
