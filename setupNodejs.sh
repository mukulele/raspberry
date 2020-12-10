#!/bin/bash
# look for Releases https://nodejs.org/de/about/releases/
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
apt-get install -y libjson-pp-perl
npm install pm2 -g
