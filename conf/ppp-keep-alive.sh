#!/bin/sh
if ping -I ppp0 -c 2 google.com &> /dev/null
then
  echo "*** Connection OK ***" >> /var/log/ppp-keep-alive
else
  poff
  wait 5
  pon
  echo "*** Connection restarted ***" >> /var/log/ppp-keep-alive
fi
