#!/bin/bash
# docker setup needs curl an should run as sudo
sudo su <<HERE
apt -y update && apt -y install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
# add user to group
usermod -aG docker $(whoami)
HERE
# for group membership new login
echo "open now a new shell for docker groupmembership"
echo "after exit you need to re login"
# sudo -su $(id -un)
