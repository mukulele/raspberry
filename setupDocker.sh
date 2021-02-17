#!/bin/bash
# docker itselfs
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
# docker-compose the actual version
sudo apt-get install -y libffi-dev libssl-dev
sudo apt-get install -y python3 python3-pip
sudo apt-get remove python-configparser
sudo pip3 install docker-compose
# portainer as solo container - must be sudo because group docker not working without logout/login
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
# make a working directory 
mkdir docker
echo "your Docker Setup is ready \n Logout and Login for Groupmembership\n after reconnect could \n  cd docker"
