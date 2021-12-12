#!/bin/bash
# docker itselfs
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# add user to group
sudo usermod -aG docker $(whoami)
# docker-compose the actual version
sudo apt-get install -y libffi-dev libssl-dev
sudo apt-get install -y python3 python3-pip
sudo pip3 install docker-compose
# portainer as solo container - must be sudo because group docker not working without logout/login
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
# make a working directory 
mkdir docker
echo -e "Hello $(whoami) - your Docker Setup is ready \n Logout and Login for docker Groupmembership\n after reconnect you could \n  cd docker"
echo -e "Portainer is running and reachable under\n   http://$(hostname):9000"
