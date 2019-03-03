# von debian.fhem.de installieren - siehe aktuelle Anleitung dort https://debian.fhem.de/
wget -qO - http://debian.fhem.de/archive.key | apt-key add -
echo "deb http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
apt-get update & upgrade
apt-get -y install fhem
wget -O fhemcl.sh https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.sh
cat <<EOF | bash fhemcl.sh 8083
attr initialUsbCheck disable 1
EOF
