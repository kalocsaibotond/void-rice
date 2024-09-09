#!/bin/bash

printf "\nUpdating The system:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syy
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -u xbps
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syu

printf "\nInstalling base desktop environment dependencies:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_base_deps.txt)

printf "\Configuring fontconfig:\n\n"
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf \
  etc/fonts/conf.d/
sudo xbps-reconfigure -f fontconfig

git config --global user.email "kalocsaibotond@gmail.com"
git config --global user.name "Botond Kalocsai"

./install_dwm.sh $1
./install_st.sh $1

printf "\nSetting up xinitrc\n\n"
touch ~/.xinitrc
echo "setxkbmap hu &" >>~/.xinitrc
echo "slstatus &" >>~/.xinitrc
echo "exec dwm" >>~/.xinitrc
echo "startx" >>~/.bash_profile
