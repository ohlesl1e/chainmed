#!/usr/bin/env bash

ssh-keygen -t rsa -P "" -b 4096 -m PEM -f jwtRS256.key
ssh-keygen -e -m PEM -f jwtRS256.key > ../client/src/assets/jwtRS256.key.pub