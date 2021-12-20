docker-compose version||echo "docker-compose nicht gefunden"
sudo rm /usr/local/bin/docker-compose > /dev/null 2>&1 && echo "/usr/local/bin/docker-compose entfernt"
sudo pip3 uninstall docker-compose > /dev/null 2>&1 && echo "docker-compose mit pip3 deinstalliert"
sudo apt purge docker-compose && sudo apt autoremove ; echo "docker-compose mit apt deinstalliert"

# docker compose v2 plugin setup https://docs.docker.com/compose/cli-command/#install-on-linux
# Replace with the latest version from https://github.com/docker/compose/releases/latest
# uname -m could be an option: ARCH=$(uname -m);echo ${ARCH:0:5}
COMPOSE_VER="2.2.2"
# For 64-bit OS use:
#COMPOSE_ARCH="aarch64"
# For 32-bit OS use:
#COMPOSE_ARCH="armv7"

COMPOSE_ARCH=$(uname -m)
if [[ ${COMPOSE_ARCH:0:3} == "arm" ]]
then
  COMPOSE_ARCH=${COMPOSE_ARCH:0:5}
fi
PLUGIN_PATH="$HOME/.docker/cli-plugins/" # for all users /usr/local/lib/docker/cli-plugins # '~' instead of $HOME will not work at this point
DOWNLOAD_PATH="https://github.com/docker/compose/releases/download/v${COMPOSE_VER}/docker-compose-linux-${COMPOSE_ARCH}"
mkdir -p ${PLUGIN_PATH}
curl -SL ${DOWNLOAD_PATH} -o ${PLUGIN_PATH}docker-compose
chmod +x ${PLUGIN_PATH}docker-compose
