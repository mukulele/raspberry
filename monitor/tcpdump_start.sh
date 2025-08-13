#!/bin/sh
rm -f nohup.out
nohup /usr/sbin/tcpdump -ni ppp0 -s 65535 -w file_result.pcap &

# Write tcpdump's PID to a file
echo $! > /var/run/tcpdump.pid
