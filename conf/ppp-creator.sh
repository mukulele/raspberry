#!/bin/sh

# Install ppp for Internet connection
echo "install ppp"
apt-get install ppp

# colored_echo
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
SET='\033[0m'

colored_echo ()
{
	COLOR=${2:-$YELLOW}
	echo -e "$COLOR$1 ${SET}"
}

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
# ATEO = echo off ATE1 = on needed for chat to operate?
# ATQ0 Report result codes (required for chat to operate).?
# OK AT+IFC=2,2
# Set TE-TA Local Data Flow Control hardware flowcontrol = 2
# To enable hardware flow control, ensure that the RTS/CTS lines are present on user’s application platform
# use hardware signal (Clear To Send/Request to Send - CTS/RTS) 
# SIM7X00 TCPIP Appliucation Note:
# OK AT+IPR=115200
# Set TE-TA Fixed Local Rate max 4000000 baud/sec, 0 = auto baud up to 115200
# OK AT&E1
# AT&E1 the data rate should be the serial connection rate
# Hardware switching: DTR pin could be used to trigger data mode and command mode.Command 
# AT&D1 should be configured before application. 
# End TCPIP Application Note
OK ATI
# Display Product Identification Information
OK AT+CFUN=1
# full functionality (CFUN=1,1 with reset)
OK AT+CPIN?
OK AT+CNMP=2 
#((2-Automatic),(13-GSM Only),(38-LTE Only),(51-GSM And LTE Only))
OK AT+CMNB=1
#((1-Cat-M),(2-NB-IoT),(3-Cat-M And NB-IoT))
OK AT+COPS=0,0
#This sets the registration process to automatic. The preferred RAT selection will still apply.
OK AT+CREG?
# Network Registration Status
OK AT+CEREG?
# connection can be checked with 'AT+CEREG?' for LTE
OK AT+CGREG?
# connection can be checked with 'AT+CEREG?' for GSM
OK AT+CPSI?
# With 'AT+CPSI?' the RAT and current status of the connection can be viewed. 
OK AT+CSQ
# Signal Quality Report
# Insert the APN provided by your network operator, default apn is #APN
OK AT+CGDCONT=1,\"IP\",\"\\T\",,0,0
# Define PDP Context 
# AT+CGDCONT=CID 1-24 ,"IP/PPP/IPV6/IPV4V6","APN",PDP address if 0.0.0.0 dynamic, compression 0=off , head compression 0=off
# Alternativ OK AT+CSTT=\"iot.1nce.net\",\"\",\"\" 
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
/dev/#DEVICE 115200
# The init script
# init script
# The chat script, customize your APN in this file
connect 'chat -s -v -f /etc/chatscripts/chat-connect -T #APN'
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
defaultroute-metric 700
# pppd must not propose any IP address to the peer
# With this option, the peer will have to supply the local IP address during IPCP negotiation
noipdefault
noipv6
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
# Hardware flow control set AT+IFC=2,2 in connect script
crtscts
#nocrtscts
# Set the assumed name of the remote system for authentication purposes to name
remotename 3gppp
# Provides an extra parameter to the ip-up, ip-pre-up and ip-down scripts. If this option is given, 
# the string supplied is given as the 6th parameter to those scripts.
ipparam 3gppp
ipcp-max-failure 30
# Ask the peer for up to 2 DNS server addresses
usepeerdns" > /etc/ppp/peers/provider

colored_echo "What is your carrier APN?"
read carrierapn 
colored_echo "Your Input is : $carrierapn" ${GREEN}
sed -i "s/#APN/$carrierapn/" /etc/ppp/peers/provider

colored_echo "What is your device communication PORT? (ttyS0/ttyUSB3/ttyAMA0 etc.)"
read devicename 
colored_echo "Your input is: $devicename" ${GREEN} 
sed -i "s/#DEVICE/$devicename/" /etc/ppp/peers/provider

# Reconnect service
SIXFAB_PATH="/opt/sixfab"
PPP_PATH="/opt/sixfab/ppp_connection_manager"

REPO_PATH="https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer"
BRANCH=master
SOURCE_PATH="$REPO_PATH/$BRANCH/src"
SCRIPT_PATH="$REPO_PATH/$BRANCH/src/reconnect_scripts"
RECONNECT_SCRIPT_NAME="ppp_reconnect.sh"
MANAGER_SCRIPT_NAME="ppp_connection_manager.sh"
SERVICE_NAME="ppp_connection_manager.service"

# Global Varibales
POWERUP_REQ=1
POWERUP_NOT_REQ=0

STATUS_GPRS=19
STATUS_CELL_IOT_APP=20
STATUS_CELL_IOT=23
STATUS_TRACKER=23

POWERKEY_GPRS=26
POWERKEY_CELL_IOT_APP=11
POWERKEY_CELL_IOT=24
POWERKEY_TRACKER=24

while [ 1 ]
do
	colored_echo "Do you want to activate auto connect/reconnect service at R.Pi boot up? [Y/n]"
        echo "This option allows you to connect to Internet via your shield automatically when your Raspberry Pi Starts."
	echo "If you have selected n then you will need to run sudo pon to connect to internet and sudo poff to stop it."
	read auto_reconnect

	colored_echo "You chose $auto_reconnect" ${GREEN} 

	case $auto_reconnect in
		[Yy]* )    
			colored_echo "Installing python3 if it is required..."
			if ! [ -x "$(command -v python3)" ]; then
			  sudo apt install python3 -y
			  if [[ $? -ne 0 ]]; then colored_echo "Process failed" ${RED}; exit 1; fi
			fi

			colored_echo "Installing pipx if it is required..."
			if ! [ -x "$(command -v pipx)" ]; then
			  sudo apt install pipx -y
                          pipx ensurepath
			  # sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
			  if [[ $? -ne 0 ]]; then colored_echo "Process failed" ${RED}; exit 1; fi
			fi

			colored_echo "Installing or upgrading atcom if it is required..."

			pipx install -U atcom
			if [[ $? -ne 0 ]]; then colored_echo "Process failed" ${RED}; exit 1; fi

			source ~/.profile
			if [[ $? -ne 0 ]]; then colored_echo "Process failed" ${RED}; exit 1; fi

			colored_echo "Installing WiringPi (gpio tool) if required..."
			
			# Check the availability of the gpio.
			gpio -v > /dev/null 2>&1
			if [[ $? -ne 0 ]]; then colored_echo "WiringPi not found\n" ${RED} ; fi 
			
			# Download WiringPi from https://github.com/WiringPi/WiringPi.git 
			git clone https://github.com/WiringPi/WiringPi.git 
			
			# change directory to WiringPi and build from source code
			pushd WiringPi && ./build && popd

			if [[ $? -ne 0 ]]; then colored_echo "WiringPi installation failed \nTry manual insatallation" ${RED} ; fi

			# # test wiringpi and fix if there is any issue
			# gpio readall | grep Oops > /dev/null
			# if [[ $? -ne 1 ]]; then 
			# 	colored_echo "Known wiringPi issue is detected! WiringPi is updating..."
			# 	# wget https://project-downloads.drogon.net/wiringpi-latest.deb
			# 	# sudo dpkg -i wiringpi-latest.deb
			# fi

			colored_echo "Downloading setup file..."
			  
			wget --no-check-certificate $SOURCE_PATH/$SERVICE_NAME
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

			wget --no-check-certificate $SOURCE_PATH/functions.sh
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

			wget --no-check-certificate $SOURCE_PATH/configs.sh
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

			wget --no-check-certificate $SOURCE_PATH/configure_modem.sh
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

			wget --no-check-certificate $SOURCE_PATH/$MANAGER_SCRIPT_NAME
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

			# APN Configuration
			sed -i "s/SIM_APN/$carrierapn/" configure_modem.sh

			if [ $shield_hat -eq 1 ]; then
			  
				wget --no-check-certificate  $SCRIPT_PATH/reconnect_gprsshield -O $RECONNECT_SCRIPT_NAME
				if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

				sed -i "s/STATUS_PIN/$STATUS_GPRS/" configure_modem.sh
				sed -i "s/POWERKEY_PIN/$POWERKEY_GPRS/" configure_modem.sh
				sed -i "s/POWERUP_FLAG/$POWERUP_REQ/" configure_modem.sh

			  
			elif [ $shield_hat -eq 2 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_baseshield -O $RECONNECT_SCRIPT_NAME
				if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

				sed -i "s/POWERUP_FLAG/$POWERUP_NOT_REQ/" configure_modem.sh
				
			
			elif [ $shield_hat -eq 5 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_tracker -O $RECONNECT_SCRIPT_NAME
				if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

				sed -i "s/STATUS_PIN/$STATUS_TRACKER/" configure_modem.sh
				sed -i "s/POWERKEY_PIN/$POWERKEY_TRACKER/" configure_modem.sh
				sed -i "s/POWERUP_FLAG/$POWERUP_REQ/" configure_modem.sh

			elif [ $shield_hat -eq 6 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_basehat -O $RECONNECT_SCRIPT_NAME
				if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

				sed -i "s/POWERUP_FLAG/$POWERUP_NOT_REQ/" configure_modem.sh

			fi
			  
			  mv functions.sh $PPP_PATH
			  mv configs.sh $PPP_PATH
			  mv configure_modem.sh $PPP_PATH
			  mv $RECONNECT_SCRIPT_NAME $PPP_PATH
			  mv $MANAGER_SCRIPT_NAME $PPP_PATH
			  mv $SERVICE_NAME /etc/systemd/system/
			  
			  systemctl daemon-reload
			  systemctl enable $SERVICE_NAME
			  
			  break;;
			  
		[Nn]* )    echo -e "${YELLOW}To connect to internet run ${BLUE}\"sudo pon\"${YELLOW} and to disconnect run ${BLUE}\"sudo poff\" ${SET}"
			  break;;
		*)   colored_echo "Wrong Selection, Select among Y or n" ${RED};;
	esac
done

read -p "Press ENTER key to reboot" ENTER

colored_echo "Rebooting..." ${GREEN}
reboot
