# Monitor to MQTT
## Concept
The script is called periodically by systemd timers. It's running two nested loops: one loop over files (assigments of variables) and second loop over the lines inside the file. 
For every variable (line) found, a MQTT message will be created and send.
There will be one inactive systemd service unit is called by 3 systemd timers with paramter. look after setup
```
systemctl list-units --all monitor*
```
There are 3 Parts: 
### main script 
The MQTT Server configuration is done by a file runMqtt.conf or inside on top of the script. The intial config is empty, in this case the script will exit witout any action.

```
./runMqtt.sh         # will send all from all var files
./runMqtt.sh second  # will proceed only the file second.var
```
### var files
The content is executed by source file statement. And analyzed line by line with cut at the '='
It's possible to do anything inside the file, but the var=value had to be at start of the line and all lines without var assigments have to start with white spaces or hash (#)!

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
### setup Script
installing mosquitto_clients (only mosquitto_pub is used)
catching the script from github and makes it executable
Create a inactive service units called bei systemd timer
Create 3 timer units: running per day, per hour and every 10 seconds
enables the timer

```
wget -qO setupMonitor.sh https://raw.githubusercontent.com/heinz-otto/raspberry/master/monitor/setupMonitor.sh
sudo bash setupMonitor.sh
```
After the setup, the script will run immediately. Create an working config and the next loop will send data. If you don't want to wait up to midnight, you could execute the script initially without anything.
Status of timer
```
systemctl status monitor*
```
control a single timer
```
sudo systemctl stop monitor-runMqtt-day@day.timer
sudo systemctl start monitor-runMqtt-day@day.timer
```
