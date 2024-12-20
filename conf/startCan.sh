# bitrate 250000 VE.Can NMEA2000
# bitrate 500000 CANbus BMS
ifconfig can0 txqueuelen 65536
ip link set can0 up type can bitrate 250000
ip link set can1 up type can bitrate 500000
sudo ifconfig can0 txqueuelen 65536
sudo ifconfig can1 txqueuelen 65536