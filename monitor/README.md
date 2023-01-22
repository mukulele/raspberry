# Monitor to MQTT
## Concept
The script is called periodically by systemd timers. It's running two nested loops: one loop over files (assigments of variables) and second loop over the lines inside the file. 
For every variable (line) found, a MQTT message will be created and send.
There will be one inactive systemd service unit is called by 3 systemd timers with paramter.

There are 3 parts of code on this repository: 
## 1. Setup Script
The setupMonitor script will do this steps:
1. install mosquitto-clients if mosquitto_pub is'nt in place.
2. download the main script and makes it's executable.
3. configure systemd to do the frequently job:
   - one inactive service unit, called by the timer
   - tree timer units: running per day, per hour and every 10 seconds
   - enables the timer

Except the last step, it's easy to do with a few lines manually, look to the section main script.

```
wget -qO setupMonitor.sh https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/setupMonitor.sh
sudo bash setupMonitor.sh
```
After the setup, the script will run immediately, but will don't send any data.
Create now a working config and the next loop will send data to your running MQTT-Broker. Edit the top of the script or create an extra file:
```
cat >runMqtt.conf <<EOF
MQTT_SVR="servername|IP"
MQTT_TOPIC="monitor/system"
#MQTT_ACCOUNT="-u user -P password"
MQTT_CID=${HOSTNAME}
EOF
```
If you don't want to wait up to midnight for all data, you could execute the script initially without anything.
```
./runMqtt.sh         # will send all data from all var files
```
### Customize your collectors 
Initially the script loads 3 collector files from github. Customize this at any time. 
```
nano second.var
```

### Control the monitor
Is all installed, looking after setup
```
systemctl list-units --all monitor*
```
Status of timer
```
systemctl status monitor*
```
control a single timer
```
sudo systemctl stop monitor-runMqtt-day@day.timer
sudo systemctl start monitor-runMqtt-day@day.timer
```
## 2. main script 
The receiver (MQTT Server) configuration is done by a file runMqtt.conf or inside on top of the script. The intial config is empty, in this case the script will exit witout any action.

```
wget -qO runMqtt.sh https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/runMqtt.sh
chmod +x runMqtt.sh
./runMqtt.sh         # will send all from all var files
./runMqtt.sh second  # will proceed only the file second.var
```
## 3. Collector (var) files
The content is executed by a source file statement inside the main script. The content is analyzed line by line with doing a cut at the '='.
It's possible to do anything inside the file, but the var=value had to be at start of the line and all lines without var assigments have to start with on or more white spaces or hash (#)!

Be aware of the spaces at start of the line for the function!
```
# functions
 countFiles () {
   ls | wc -l
 }
# variables
var1=value1
var2=$(countFiles)
var3=$(date)
```
