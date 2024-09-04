#!/bin/bash

echo "Updating The System"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syy
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -u xbps
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syu

echo "Installing base desktop environment dependencies"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_base_deps.txt)

./install_dwm.sh $1

touch ~/.xinitrc
echo "setxkbmap us &" >>~/.xinitrc
echo "exec dwm" >>~/.xinitrc
echo "startx" >>~/.bash_profile
