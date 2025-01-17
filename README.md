
## Scripts for setup raspberryPi
Here are some short Scripts for setup a new raspberry und do some configuration inside.
After download - the script should be executed with bash and sudo.
```
sudo bash <scriptname>
```
Short description the Basic Script in sort of usage:

* Basic   will setup all Basic things like last basic util software, networkmanger, journalctl
* Uart    is not used
* Samba   is not used
* Davfs   is not used
* Docker  is not configured
* PiVCCU  is not used
* Ser2net is not used
* Can     will setup the CANbus hardware
* Wifi    hotspot for local access when internet connectivity is down
* Uart    Sim7000 and PPP
* Gpsd    noname usb device with gpxlogger and NMEA stream on port 2947

Some extended Script for a ready System  
* configBackup...   not used
* setupNodejs       not used
* signalk           @todo
# Download a bunch of Scripts 

For Setup
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,Can.sh,Gpsd.sh,Uart.sh,Wifi.sh}
```

For Docker
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,Uart.sh,BasisDocker.sh,PiVCCU.sh}
```
For system migration and testing
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,Uart.sh,Prereq.sh}
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/{SIM7000-DEMO.zip,Sim7000x-master.zip,DFRobot_SIM7000-master.zip}
```
