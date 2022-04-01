#!/bin/bash
# docker setup needs curl an should run as sudo
is_user_root () { [ "$(id -u)" -eq 0 ]; }
is_user_root && echo "run script as normal user" && exit 1
###
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
