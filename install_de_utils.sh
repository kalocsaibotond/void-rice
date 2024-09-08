#!/bin/bash

# Installing other utilites of my desktop environment
printf "\nLastly installing the utilites of my desktop environment:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_util_deps.txt)

chezmoi init kalocsaibotond
