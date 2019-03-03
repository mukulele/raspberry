#!/bin/bash
spath="/var/SonosSpeak"
apt-get install samba

# Pfad erstellen
mkdir $spath
chmod 777 $spath

# Share Definition in /etc/samba/smb.conf
cat <<EOF >> /etc/samba/smb.conf
[SonosSpeak]
  comment = Audio-Files for SonosPlayer to Speak
  path = $spath
  browsable = yes
  guest ok = yes
  read only = no
EOF

# restart Service
systemctl restart smbd
