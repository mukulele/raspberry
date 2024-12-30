#!/bin/sh

echo "install ppp"
apt-get install ppp

echo "creating directories"
mkdir -p /etc/chatscripts
mkdir -p /etc/ppp/peers

echo "creating script file : /etc/chatscripts/simcom-chat-connect"
echo "
ABORT \"BUSY\"
ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
TIMEOUT 30
\"\" AT
OK ATE0
OK ATI;+CSUB;+CSQ;+CPIN?;+COPS?;+CGREG?;&D2
# Insert the APN provided by your network operator, default apn is $1
OK AT+CGDCONT=1,\"IP\",\"\\T\",,0,0
OK ATD*99#
CONNECT" > /etc/chatscripts/simcom-chat-connect

echo "creating script file : /etc/chatscripts/simcom-chat-disconnect"
echo "
ABORT \"ERROR\"
ABORT \"NO DIALTONE\"
SAY \"\nSending break to the modem\n\"
""  +++
""  +++
""  +++
SAY \"\nGoodby\n\"" > /etc/chatscripts/simcom-chat-disconnect

echo "creating script file : /etc/chatscripts/ratCat-M"
echo "
ABORT \"BUSY\"
ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
TIMEOUT 30
\"\" AT
OK AT+CFUN=1
OK AT+CPIN?
OK AT+CNMP=38 
#((2-Automatic),(13-GSM Only),(38-LTE Only),(51-GSM And LTE Only))
OK AT+CMNB=1
#((1-Cat-M),(2-NB-IoT),(3-Cat-M And NB-IoT))
OK" > /etc/chatscripts/ratCat-M

echo "creating script file : /etc/chatscripts/Reg-1nce"
echo "
ABORT \"BUSY\"
ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
TIMEOUT 30
\"\" AT
OK AT+CFUN=1
OK AT+COPS=0,0
#This sets the registration process to automatic. The preferred RAT selection will still apply.
OK AT+CEREG?
# connection can be checked with 'AT+CEREG?' for LTE
OK" > /etc/chatscripts/Reg-1nce

echo "creating script file /etc/chatscripts/1nce-connect"
echo "
ABORT \"BUSY\"
ABORT \"NO CARRIER\"
ABORT \"NO DIALTONE\"
ABORT \"ERROR\"
ABORT \"NO ANSWER\"
TIMEOUT 30
\"\" AT
OK AT+CFUN=1
OK AT+CIPSTATUS
# If the response is not IP INITIAL, deactivate the GPRS PDP Context and check the status again.
# Set the APN and connect @todo...
IP INITIAL AT+CSTT='"iot.1nce.net","",""'
OK AT+CIICR
OK AT+CIFSR
IP ADDRESS" > /etc/chatscripts/1nce-connect 
#AT+CIPSTART="TCP","cloudsocket.hologram.io",9999
#OK
#CONNECT OK" > /etc/chatscripts/1nce-connect


echo "creating script file : /etc/ppp/peers/gprs"
echo "
/dev/$2 115200
# The chat script, customize your APN in this file
connect 'chat -s -v -f /etc/chatscripts/simcom-chat-connect -T $1'
# The close script
disconnect 'chat -s -v -f /etc/chatscripts/simcom-chat-disconnect'
# Hide password in debug messages
hide-password
# The phone is not required to authenticate
noauth
# Debug info from pppd
debug
# If you want to use the HSDPA link as your gateway
defaultroute
# pppd must not propose any IP address to the peer
noipdefault
# No ppp compression
novj
novjccomp
noccp
ipcp-accept-local
ipcp-accept-remote
local
# For sanity, keep a lock on the serial line
lock
modem
dump
nodetach
# Hardware flow control
nocrtscts
remotename 3gppp
ipparam 3gppp
ipcp-max-failure 30
# Ask the peer for up to 2 DNS server addresses
usepeerdns" > /etc/ppp/peers/gprs

echo "\n\nUse \"sudo pppd call gprs\" command and Surf"

#@todo
echo "creating script file : /etc/ppp/peers/catm"
echo "
/dev/$2 115200
# The chat script, customize your APN in this file
connect 'chat -s -v -f /etc/chatscripts/1nce-connect -T $1'
# The close script
disconnect 'chat -s -v -f /etc/chatscripts/simcom-chat-disconnect'
# Hide password in debug messages
hide-password
# The phone is not required to authenticate
noauth
# Debug info from pppd
debug
# If you want to use the HSDPA link as your gateway
nodefaultroute
# pppd must not propose any IP address to the peer
noipdefault
# No ppp compression
novj
novjccomp
noccp
ipcp-accept-local
ipcp-accept-remote
local
# For sanity, keep a lock on the serial line
lock
modem
dump
nodetach
# Hardware flow control
nocrtscts
remotename 3gppp
ipparam 3gppp
ipcp-max-failure 30
# Ask the peer for up to 2 DNS server addresses
usepeerdns" > /etc/ppp/peers/catm

echo "\n\nUse \"sudo pppd call catm\" command and Surf"
