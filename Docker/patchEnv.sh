#!/bin/sh
# patch .env File with real data
# for test remove -i option
sed -i s/SONOS2MQTT_DEVICE=.*$/SONOS2MQTT_DEVICE=$(host -4 -W1 -t A  SonosZP | awk '/has address/ { print $NF; exit }')/ .env
sed -i "s/SONOS2MQTT_MQTT=.*$/SONOS2MQTT_MQTT=mqtt:\/\/$(hostname):1883/" .env
sed -i "s/SONOS_LISTENER_HOST=.*$/SONOS_LISTENER_HOST=$(hostname)/" .env
