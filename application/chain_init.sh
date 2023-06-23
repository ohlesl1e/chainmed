#!/bin/bash

sudo apt update && sudo apt upgrade

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

sudo npm install -g ganache

ganache -h 10.128.0.6 -b -p 7545 -s 4096 -b 16 --chain.chainId 5777 -D
