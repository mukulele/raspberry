#!/bin/bash
# run as user
# docker itselfs
sudo apt update && sudo apt install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# add user to group
sudo usermod -aG docker $(whoami)
##
