#!/bin/bash
# replace the name "mymachine" lines below
# Timezone
timedatectl set-timezone Europe/Berlin

# config the language to german
sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
localectl set-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE

# Hostname 
hostnamectl set-hostname mymachine

# Reboot
reboot
