#!/bin/sh

GREEN='\033[0;32m'

echo "install ppp"
apt-get install ppp

echo "creating directories"
mkdir -p /etc/chatscripts
mkdir -p /etc/ppp/peers

echo "creating script file : /etc/chatscripts/chat-connect"
echo "
ABORT \"BUSY\"
ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
TIMEOUT 30
\"\" AT
OK ATE0
OK AT+CFUN=1
OK AT+CPIN?
OK AT+CNMP=38 
#((2-Automatic),(13-GSM Only),(38-LTE Only),(51-GSM And LTE Only))
OK AT+CMNB=1
#((1-Cat-M),(2-NB-IoT),(3-Cat-M And NB-IoT))
OK AT+COPS=0,0
#This sets the registration process to automatic. The preferred RAT selection will still apply.
OK AT+CEREG?
# connection can be checked with 'AT+CEREG?' for LTE
# OK ATI;+CSUB;
# OK AT+CSQ
# OK AT+CREG?
# OK AT+CGREG?
# Insert the APN provided by your network operator, default apn is $1
OK AT+CGDCONT=1,\"IP\",\"\\T\",,0,0
OK ATD*99#
CONNECT" > /etc/chatscripts/chat-connect

echo "creating script file : /etc/chatscripts/chat-disconnect"
echo "
ABORT \"ERROR\"
ABORT \"NO DIALTONE\"
SAY \"\nSending break to the modem\n\"
""  +++
""  +++
""  +++
SAY \"\nGoodby\n\"" > /etc/chatscripts/chat-disconnect

echo "creating script file : /etc/ppp/peers/provider"
echo "
/dev/$2 115200
# The init script
# init script
# The chat script, customize your APN in this file
connect 'chat -s -v -f /etc/chatscripts/chat-connect -T $1'
# The close script
disconnect 'chat -s -v -f /etc/chatscripts/chat-disconnect'
# Hide password in debug messages
hide-password
# The phone is not required to authenticate
noauth
# Do not exit after a connection is terminated; instead try to reopen the connection.
persist
# Set the MTU [Maximum Transmit Unit]
mtu 1200
# Debug info from pppd
debug
# If you want to use the HSDPA link as your gateway @tocheck
defaultroute
# pppd must not propose any IP address to the peer
# With this option, the peer will have to supply the local IP address during IPCP negotiation
noipdefault
# No ppp compression
novj
novjccomp
# This option should only be required if the peer is buggy and gets confused by requests from pppd for CCP negotiation.
noccp
# With this option, pppd will accept the peer's idea of our local IP address, even if the local IP address was specified in an option.
ipcp-accept-local
# With this option, pppd will ignore the state of the CD (Carrier Detect) signal from the modem and 
# will not change the state of the DTR (Data Terminal Ready) signal. This is the opposite of the modem option.
local
# For sanity, keep a lock on the serial line
lock
# With this option, pppd will wait for the CD (Carrier Detect) signal from the modem to be asserted when opening the serial device
# (unless a connect script is specified), and it will drop the DTR (Data Terminal Ready) signal briefly when the connection
# is terminated and before executing the connect script. 
modem
# pppd will print out all the option values which have been set
dump
nodetach
# Hardware flow control
nocrtscts
# Set the assumed name of the remote system for authentication purposes to name
remotename 3gppp
# Provides an extra parameter to the ip-up, ip-pre-up and ip-down scripts. If this option is given, 
# the string supplied is given as the 6th parameter to those scripts.
ipparam 3gppp
ipcp-max-failure 30
# Ask the peer for up to 2 DNS server addresses
usepeerdns" > /etc/ppp/peers/provider

echo "\n\nUse \"sudo pon poff\" command to connect disconnect"

read -p "Press ENTER key to reboot" ENTER

colored_echo "Rebooting..." ${GREEN}
reboot
