#!/bin/bash
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
# von debian.fhem.de installieren - siehe aktuelle Anleitung dort https://debian.fhem.de/
# temporärer Workaround wenn mal das Paket nicht signiert ausgeliefert wird   
# echo "deb [trusted=yes] http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
if [[ "$(apt list fhem)" =~ "installed" ]];then
    echo fhem ist bereits installiert
else
  if [ "$(wget -qO - http://debian.fhem.de/archive.key | apt-key add -)" = "OK" ];then
    echo "deb http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
    apt-get update
    apt-get install fhem
  else
    echo Es gab ein Problem mit dem debian.fhem.de/archive.key
    exit 1
  fi
fi

apt-get update
apt-get upgrade

# get additional Package Files
# check if local Package Files exist
getFile fhemDeb.txt raspberry
getFile fhemCpan.txt raspberry

# install debian packages, drop lines with comment #
# This Version works not very stable in case of longer list
#apt-get -y install $(cat fhemDeb.txt |grep -v '#'|tr -d "\r"|tr "\n" " ")
cat fhemDeb.txt |grep -v '#'|sed 's/^\(.\)/apt-get -y install \1/'|bash -
# Update cpan first, then install cpan packages, drop lines with comment #
export PERL_MM_USE_DEFAULT=1
cpan install CPAN
cpan install $(cat fhemCpan.txt |grep -v '#'|tr -d "\r"|tr "\n" " ")

# Setup FHEM
apt-get install fhem
# e.g. in WSL the Service isn't started, start it
cmd="perl fhem.pl fhem.cfg"
if ! pidof $cmd; then
  cd /opt/fhem
  sudo -u fhem $cmd
  echo $cmd is starting by workaround
  cd ~
else
  echo $cmd always running
fi
##
usermod -aG audio fhem   # for TTS

# get the HTTP Client
getFile fhemcl.sh fhemcl

# setup a Basic Configuration
# get the dns Server entry for use in the Basic configuration
dat=($(cat /etc/resolv.conf|grep nameserver))

cat <<EOF | bash fhemcl.sh 8083
attr initialUsbCheck disable 1
attr WEB JavaScripts codemirror/fhem_codemirror.js
attr WEB codemirrorParam { "lineNumbers":true }
attr WEB plotfork 1
attr WEB plotEmbed 2
attr WEB longpoll websocket
attr global backup_before_update 1
attr global commandref modular
attr global title FHEM-Name
attr global sendStatistics onUpdate
attr global language DE
attr global dnsServer ${dat[1]}
attr global restoreDirs 10

save
EOF
#attr global latitude 51.xxxxxxxxxxxxx
#attr global longitude 12.xxxxxxxxxxxxx
