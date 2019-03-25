# von debian.fhem.de installieren - siehe aktuelle Anleitung dort https://debian.fhem.de/
wget -qO - http://debian.fhem.de/archive.key | apt-key add -
echo "deb http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
apt-get update
apt-get upgrade
# get additional Package Files
wget -O fhemDeb.txt https://raw.githubusercontent.com/heinz-otto/raspberry/master/fhemDeb.txt
wget -O fhemCpan.txt https://raw.githubusercontent.com/heinz-otto/raspberry/master/fhemCpan.txt
# install debian packages
apt-get -y install $(cat fhemDeb.txt |tr -d "\r"|tr "\n" " ")
# install Cpan packages
cpan install $(cat fhemCpan.txt |tr -d "\r"|tr "\n" " ")
# Setup FHEM
apt-get -y install fhem
wget -O fhemcl.sh https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.sh
cat <<EOF | bash fhemcl.sh 8083
attr initialUsbCheck disable 1
attr WEB JavaScripts codemirror/fhem_codemirror.js
attr WEB codemirrorParam { "theme":"blackboard", "lineNumbers":true }
attr WEB plotfork 1
attr WEB longpoll websocket
attr global backup_before_update 1
attr global commandref modular
attr global title FHEM-Name
attr global sendStatistics onUpdate
attr global language de
EOF
#attr global latitude 51.xxxxxxxxxxxxx
#attr global longitude 12.xxxxxxxxxxxxx
