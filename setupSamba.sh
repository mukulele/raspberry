#!/bin/bash
spath="/var/SonosSpeak"
scomment="Audio-Files for SonosPlayer to Speak"
share='SonosSpeak'
apt-get install samba

# Pfad erstellen
mkdir -p $spath
chmod 777 $spath

# Share Definition in /etc/samba/smb.conf
cat <<EOF >> /etc/samba/smb.conf
[$share]
  comment = "$scomment"
  path = "$spath"
  browsable = yes
  guest ok = yes
  read only = no
EOF

# restart Service
# systemctl restart smbd
# reload config
smbcontrol smbd reload-config
