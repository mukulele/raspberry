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
function setup-Fhem {
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
    apt update
    apt install fhem
  else
    echo Es gab ein Problem mit dem debian.fhem.de/archive.key
    exit 1
  fi

}

function analyze-config {
# Abfrage starten
s=$(./fhemcl.sh 8083 "get installer checkPrereqs $1"|grep -oE 'installPerl.*&fwcsrf'|grep -oE '\s[a-z,A-Z,:]+\s')
packages=$(echo $s|tr " " "\n"|sed 's/$/./;s/^/\//'|apt-file search -l -f -)

# fehlende Pakete installieren
echo "es fehlen Pakete"
echo $packages
echo 'apt install $packages'
}
# System aufrüsten
PKG="libperl-prereqscanner-notquitelite-perl"
if dpkg-query -l $PKG > /dev/null
 then
      echo "System schon aufgerüstet"
  else
      apt update
      apt install apt-file libperl-prereqscanner-notquitelite-perl
      apt-file update
fi
# fhem installieren
PKG="fhem"
dpkg-query -l $PKG > /dev/null || setup-Fhem

# get the HTTP Client
getFile fhemcl.sh fhemcl

# Definition zum Testen erstellen
if [[ "$(./fhemcl.sh 8083 "list installer installerMode")" =~ "developer" ]] ;then
    echo "Installermodul bereits eingerichtet"
else
cat <<EOF | ./fhemcl.sh 8083
attr initialUsbCheck disable 1
defmod installer Installer
attr installer installerMode developer
save
EOF

fi

if [[ $ref = "" ]]
  then
  read -p "Dateiname eingeben:"ref
fi

if [ -s $ref ]
then
  echo "Analyse mit Datei $ref wird gestartet"
  analyze-config $ref
fi
