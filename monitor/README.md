# Monitor to MQTT
## Concept
The main idea was to collect some performance data from raspberry Pi and push this data to a mqtt broker enabled Dashboard like FHEM or HA etc. But you can use it to push every data from system level to a mqtt broker. My guideline was 'keep it simple'. The script himself don't need special rights, maybe the collectors need it.

The script could be run everywhere and performs two nested loops:
1. one loop over files, that could contain definitions of functions and variables. This files will be executed.
2. second loop over the lines inside the files, 
   - cut the names of the variables and 
   - build topics with the names and send the content as message to the mqtt broker.
3. Easy configuration by a small set of text files located in the same directory. 

Periodically starting the Script could be done by systemd timers, crontab or anything else. 

There are 3 parts of code on this repository: 
## 1. Setup Script
The setupMonitor script will do this steps:
1. apt install mosquitto-clients - if mosquitto_pub is'nt in place.
2. download the main script and make it's executable.
3. configure systemd to doing the frequently job:
   - one inactive service unit, called by the timer
   - tree active timer units: running per day, per hour and every 10 seconds
   - enables the timer

Except the last step, it's also easy doing with a few lines manually, look to the section [main script](README.md#2-main-script).

```
wget -qO setupMonitor.sh https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/setupMonitor.sh
sudo bash setupMonitor.sh
```
After the setup, the script will run immediately, but will don't send any data.
Create now a working configuration file and the next loop will send data to your running MQTT-Broker. Edit the top of the script or create an extra file:
```
cat >runMqtt.conf <<'EOF'
MQTT_SVR="servername|IP[ -p 1883]"
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
Is all installed, looking after setup: Is all installed?
```
systemctl list-units --all monitor*
```
Status of timer?
```
systemctl status monitor*
```
Control a single timer:
```
sudo systemctl stop monitor-runMqtt-day@day.timer
sudo systemctl start monitor-runMqtt-day@day.timer
```
## 2. main script 
The receiver (MQTT Server) configuration is done by a file runMqtt.conf or inside on top of the script. The intial config is empty, in this case the script will exit without any further action. Get only the file and run:
```
wget -qO runMqtt.sh https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/runMqtt.sh
chmod +x runMqtt.sh
./runMqtt.sh         # will send all from all var files
./runMqtt.sh second  # will proceed only the file second.var
```
If you want doing only a small test bevor going live: create an valid conf file (see above) and a harmless collector:
```
cat >second.var <<'EOF'
MESSAGE="$(date) msg from the runMqtt script"
EOF
```
Remove this file, if you want to downloading the collector templates automatically during the first run.
## 3. Collector (var) files
The content is executed by a source file statement inside the main script. Also, the content is analyzed line by line with doing a cut at the '='.
It's possible to do anything inside the file, but the 'var=value' statement must to be at start of the line and all lines without var assigments have to start with one or more white space or hash (#)!

More details in this [document](getValues.md)

Example:
* Be aware of the spaces at start of the line for the function!
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
