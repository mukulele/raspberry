# raspberry
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
* Docker  will setup Docker and docker-compose
* PiVCCU  is not used
* Ser2net is not used
* CAN     will setup the CANbus hardware

Some extended Script for a ready System  
* configBackup...   Implement a Backup Solution wich copies the lokal Backup to a SMB Server and is triggered from FHEM
* setupNodejs         Simple install a defined Version of nodejs. Please look at https://nodejs.org/de/about/releases/
# Download a bunch of Scripts 
For Docker
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,Uart.sh,BasisDocker.sh,PiVCCU.sh}
```
For system migration and testing
```
wget -N https://raw.githubusercontent.com/mukulele/raspberry/master/setup{Basic.sh,Uart.sh,Prereq.sh}
```
