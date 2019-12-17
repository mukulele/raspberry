# raspberry
Scripts for setup raspberryPi.  
Here are some short Scripts for setup a new raspberry und do some configuration inside.
All scripts are designed more or less from the FHEM point of view.  
Short description the Basic Script in sort of usage:

* Basic will setup all Basic things like last software, language, hostname
* UartPi3 will prepare the Pi with Wlan & BT equipped to use also a Modul on GPIO UART
* Samba   will setup a samba Server with an open share for using Sonos Text2Speech
* Davfs   will setup the usage of a WebDav cloud service like magenta
* Fhem    will setup FHEM "the easy way" & Softwarepacks from the fhem*.txt Files and make some basic configuration too

Some extended Script for a ready System  
* configBackup...   Implement a Backup Solution wich copies the lokal Backup to a SMB Server and is triggered from FHEM
* setupNodejs         Simple install a defined Version of nodejs. Please look at https://nodejs.org/de/about/releases/
