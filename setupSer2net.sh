#!/bin/bash
apt -y update
apt -y install ser2net
version=($(ser2net -v))
if (( ${version[2]:0:1} < 4 )) ; then 
  echo "4000:raw:0:/dev/ttyAMA0:115200 NONE 1STOPBIT 8DATABITS HANGUP_WHEN_DONE" >> /etc/ser2net.conf
  systemctl restart ser2net
  exit
fi

# find line in file beginning with sLine and replace the end of line with rString, than create a new file 
fileIn='/lib/systemd/system/ser2net.service'
fileOut='/etc/systemd/system/ser2net.service'
sLine='Documentation=man:ser2net(8)'
rString='\nAfter=network-online.target\nWants=network-online.target'
sed "/^$sLine/ s/$/$rString/" $fileIn > $fileOut

# save configuration file and build new one
cp /etc/ser2net.yaml /etc/ser2net.yaml.sav
cat <<EOI > /etc/ser2net.yaml
%YAML 1.1
---
# HM_MOD-RPI-PCB
connection: &con01
    accepter: tcp,4000
    connector: serialdev,
              /dev/ttyAMA0,
              115200n81,local
EOI
# apply all changes
systemctl reenable ser2net.service
