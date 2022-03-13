#!/bin/sh
# install docker compose v2 plugin
# first test and try to remove docker-compose v1
if docker-compose version 
then
  sudo rm /usr/local/bin/docker-compose > /dev/null 2>&1 && echo "/usr/local/bin/docker-compose removed"
  sudo pip3 uninstall -y docker-compose > /dev/null 2>&1 && echo "docker-compose pip3 uninstalled"
  sudo apt purge docker-compose && sudo apt autoremove && echo "docker-compose apt purged"
else
  echo "docker-compose v1 not found"
fi
# docker compose v2 plugin setup https://docs.docker.com/compose/cli-command/#install-on-linux
# get the latest version from https://github.com/docker/compose/releases/latest
COMPOSE_VER=$(wget -qO - https://github.com/docker/compose/releases/latest|grep '<title>'|awk '{print $2}')
# remove the last case if it's arm
# tested with armv6l, armv7l and x86_64
COMPOSE_ARCH=$(uname -m)
if [ ${COMPOSE_ARCH:0:3} == "arm" ]
then
  COMPOSE_ARCH=${COMPOSE_ARCH:0:5}
fi
PLUGIN_PATH="$HOME/.docker/cli-plugins/" # for all users /usr/local/lib/docker/cli-plugins # '~' instead of $HOME will not work at this point
DOWNLOAD_PATH="https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-linux-${COMPOSE_ARCH}"
mkdir -p ${PLUGIN_PATH}
curl -SL ${DOWNLOAD_PATH} -o ${PLUGIN_PATH}docker-compose
chmod +x ${PLUGIN_PATH}docker-compose
# test success
docker compose version
