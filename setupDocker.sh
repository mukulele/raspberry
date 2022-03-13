#!/bin/bash
# run as user
# docker itselfs
sudo apt update && sudo apt install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# add user to group
sudo usermod -aG docker $(whoami)
##
# docker compose v2 plugin setup https://docs.docker.com/compose/cli-command/#install-on-linux
# Replace with the latest version from https://github.com/docker/compose/releases/latest
# uname -m could be an option: ARCH=$(uname -m);echo ${ARCH:0:5}
# COMPOSE_VER="v2.2.3"
COMPOSE_VER=$(wget -qO - https://github.com/docker/compose/releases/latest|grep '<title>'|awk '{print $2}')
# For 64-bit OS use:
# COMPOSE_ARCH="aarch64"
# For 32-bit OS use:
# COMPOSE_ARCH="armv7"
ARCH=$(uname -m);[ "${ARCH:0:3}" = "arm" ] && ARCH=${ARCH:0:5}
COMPOSE_ARCH=${ARCH}
PLUGIN_PATH="$HOME/.docker/cli-plugins/" # for all users /usr/local/lib/docker/cli-plugins # '~' instead of $HOME will not work at this point
DOWNLOAD_PATH="https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-linux-${COMPOSE_ARCH}"
mkdir -p ${PLUGIN_PATH}
curl -SL ${DOWNLOAD_PATH} -o ${PLUGIN_PATH}docker-compose
chmod +x ${PLUGIN_PATH}docker-compose
##
# docker-compose setup as container
#sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose
#sudo chmod +x /usr/local/bin/docker-compose
# docker-compose setup with pip
#sudo apt-get install -y libffi-dev libssl-dev
#sudo apt-get install -y python3 python3-pip
#sudo pip3 install docker-compose
read -p "portainer installieren?, Yy oder einfach enter:" input
	if [[ $input != "" ]] ;	then
      # portainer as solo container - sudo -su $(id -un) give the trick to get new groupmembership without extra logout/login
      sudo -su $(id -un) docker volume create portainer_data
      sudo -su $(id -un) docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
	fi
# make a working directory 
mkdir -p "$HOME/docker"
echo -e "Hello $(whoami) - your Docker Setup is ready \n Logout and Login for docker Groupmembership\n after reconnect you could \n  cd docker"
echo -e "Portainer is running and reachable under\n   http://$(hostname):9000"
