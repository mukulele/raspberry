#!/bin/bash
# run as user
# docker itselfs
wget https://raw.githubusercontent.com/heinz-otto/raspberry/master/Docker/setup{Docker.sh,DockerComposeV2.sh}
bash setupDocker.sh
bash setupDockerComposeV2.sh
# make a working directory 
mkdir -p "$HOME/docker"
read -p "Setup portainer?, Yy - nothing for no:" input
  if [[ $input != "" ]] ; then
      # portainer as solo container - sudo -su $(id -un) give the trick to get new groupmembership without extra logout/login
      sudo -su $(id -un) docker volume create portainer_data
      sudo -su $(id -un) docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
      echo -e "Portainer is running and reachable under\n   http://$(hostname):9000"
  fi
echo -e "Hello $(whoami) - your Docker Setup is ready \n Logout and Login for docker Groupmembership\n after reconnect you could \n  cd docker"
