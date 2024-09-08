#!/bin/bash

printf "\nInstalling dwm\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/dwm
cd dwm
sudo git checkout -b my_dwm

# Set win key as mod
sudo sed -i 's/^#define MODKEY Mod1Mask$/#define MODKEY Mod4Mask/' \
  ./config.def.h

# Eliminating all window rules.
sudo sed -i '/Gimp/d' ./config.def.h
sudo sed -i 's/{ "Firefox.*/{ NULL,       NULL,       NULL,'$(
)'       0,            False,       -1 },/' ./config.def.h

sudo git add ./config.def.h
sudo git commit -m "feat: setup my base dwm version"
sudo make
sudo make clean install
