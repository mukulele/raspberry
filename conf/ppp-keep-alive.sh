#!/bin/bash
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

if ping -I ppp0 -c 2 google.com &> /dev/null
then
  printf '%(%Y-%m-%d %H:%M:%S)T OK\n' -1 >> /var/log/ppp-keep-alive
  OUT="$(ifconfig eth0 | grep bytes)"
  echo "${OUT}" >> /var/log/ppp-keep-alive >> /var/log/keep-alive
else
  printf '%(%Y-%m-%d %H:%M:%S)T FAIL\n' -1 >> /var/log/ppp-keep-alive
  pon
fi
