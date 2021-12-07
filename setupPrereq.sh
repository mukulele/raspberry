#!/bin/bash
# Wo liegt die zu prüfende Datei?
ref='/home/pi/fhem.cfg'

#functions
# getFile FileName RepositoryName
function getFile {
  if [ ! -e $1 ]
  then
    echo "$1 is missing"
    wget https://raw.githubusercontent.com/heinz-otto/$2/master/$1
    chmod +x $1
  fi
}
# System aufrüsten
sudo apt install apt-file libperl-prereqscanner-notquitelite-perl
sudo apt-file update

if [[ "$(apt list fhem)" =~ "installed" ]] ;then
    echo fhem ist bereits installiert
else
  # get debian version strings with dot sourcing
  . /etc/os-release
  if [ $VERSION_ID -ge 10 ] ;then
    apt install gpg
    if wget -qO - https://debian.fhem.de/archive.key | gpg --dearmor > /usr/share/keyrings/debianfhemde-archive-keyring.gpg ;then
      echo "deb [signed-by=/usr/share/keyrings/debianfhemde-archive-keyring.gpg] https://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
      key='ok'
    fi
  else 
    if [ "$(wget -qO - http://debian.fhem.de/archive.key | apt-key add -)" = "OK" ] ;then
      echo "deb http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
      key='ok'
    fi
  fi
  if [ $key = 'ok' ] ;then
    apt-get update
    apt-get install fhem
  else
    echo Es gab ein Problem mit dem debian.fhem.de/archive.key
    exit 1
  fi
fi

# get the HTTP Client
getFile fhemcl.sh fhemcl

# Definition zum Testen erstellen
cat <<EOF | ./fhemcl.sh 8083
attr initialUsbCheck disable 1
define installer installer
attr installer installerMode developer
save
EOF

exit
# Abfrage starten
s=$(./fhemcl.sh 8083 "get installer checkPrereqs $ref"|grep -oE 'installPerl.*&fwcsrf'|grep -oE '\s[a-z,A-Z,:]+\s')
echo $s|tr " " "\n"|sed 's/$/./;s/^/\//'|apt-file search -l -f -
packages=$(echo $s|tr " " "\n"|sed 's/$/./;s/^/\//'|apt-file search -l -f -)

# fehlende Pakete installieren
echo "Setup this Packages $packages"
sudo apt install $packages
