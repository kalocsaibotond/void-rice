#!/bin/sh

printf "\nInstalling dwm\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/dwm
cd dwm
sudo git checkout -b my_dwm

printf "\nConfiguring dwm\n\n"
sudo cp config.def.h config.h

# Set win key as mod
sudo sed -i 's/^#define MODKEY Mod1Mask$/#define MODKEY Mod4Mask/' \
  ./config.h
# Eliminating all window rules.
sudo sed -i '/Gimp/d' ./config.h
sudo sed -i 's/{ "Firefox.*/{ NULL,       NULL,       NULL,'$(
)'       0,            False,       -1 },/' ./config.h

sudo git add ./config.h
sudo git commit -m "feat: setup my base dwm version"
sudo make
sudo make clean install
