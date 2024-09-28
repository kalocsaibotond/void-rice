#!/bin/bash

printf "\nUpdating The system:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syy
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -u xbps
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syu

printf "\nInstalling base desktop environment dependencies:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_base_deps.txt)

printf "\nConfiguring fontconfig:\n\n"
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf \
  /etc/fonts/conf.d/
sudo xbps-reconfigure -f fontconfig

printf "\nConfiguring git:\n\n"
sudo git config --global user.email "kalocsaibotond@gmail.com"
sudo git config --global user.name "Botond Kalocsai"

printf "\nConfiguring gpm to not start at boot:\n\n"
# Configuring gpm
sudo touch /etc/sv/gpm/down # I dont want it to start at boot
sudo ln -s /etc/sv/gpm /var/service

./install_dwm.sh $1
./install_st.sh $1
./install_tabbed.sh $1

printf "\nSetting up xinitrc\n\n"
suckless_xinitrc="setxkbmap hu & slstatus & exec dwm"
if ! grep -q "$suckless_xinitrc" ~/.xinitrc; then
  echo "$suckless_xinitrc" >>~/.xinitrc
fi
if ! grep -q "startx" ~/.bash_profile; then
  printf "\n\nstartx\n" >>~/.bash_profile
fi
