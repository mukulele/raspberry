# portainer as solo container - sudo -su $(id -un) give the trick to get new groupmembership without extra logout/login
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
echo -e "Portainer is running and reachable under\n   http://$(hostname):9000"
