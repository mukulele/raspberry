
## Scripts for setup raspberryPi
Here are some short Scripts for setup a new raspberry und do some configuration inside.
After download - the script should be executed with bash and sudo.
```
sudo bash <scriptname>
```
Short description the Basic Script in sort of usage:

* Basic   will setup all Basic things like last basic util software, networkmanger, journalctl
* Docker  is not configured
* Can     will setup the CANbus hardware
* Wifi    hotspot for local access when internet connectivity is down
* Uart    Sim7000 and PPP
* Gpsd    noname usb device, gpxlogger, NMEA stream on port 2947, chrony

Some extended Script for a ready System  
* configBackup...   not used
* setupNodejs       not used
# Download 
(make repo public before)

For Setup
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,Can.sh,Gpsd.sh,Uart.sh,Wifi.sh}
chmod +x *.sh
```

For Docker
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,BasisDocker.sh}
chmod +x *.sh
```
For system migration and testing
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/{SIM7000-DEMO.zip,Sim7000x-master.zip,DFRobot_SIM7000-master.zip}
```
