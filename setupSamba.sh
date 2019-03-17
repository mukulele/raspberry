#!/bin/bash
spath="/var/SonosSpeak"
scomment="Audio-Files for SonosPlayer to Speak"
apt-get install -Y samba

# Pfad erstellen
mkdir $spath
chmod 777 $spath

# Share Definition in /etc/samba/smb.conf
cat <<EOF >> /etc/samba/smb.conf
[SonosSpeak]
  comment = "$scomment"
  path = "$spath"
  browsable = yes
  guest ok = yes
  read only = no
EOF

# restart Service
systemctl restart smbd
