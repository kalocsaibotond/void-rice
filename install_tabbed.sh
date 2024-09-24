#!/bin/bash

printf "\nInstalling tabbed\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/tabbed
cd tabbed
sudo git checkout -b my_tabbed

printf "\nDownloading patches:\n\n"
sudo mkdir patches
cd patches
if [ true = "$1" ]; then # Downloading patches without SSL check
  sudo wget --no-check-certificate \
    https://tools.suckless.org/tabbed/patches/clientnumber/tabbed-clientnumber-0.6.diff
  sudo wget --no-check-certificate \
    https://tools.suckless.org/tabbed/patches/xft/tabbed-0.6-xft.diff
else
  sudo wget https://tools.suckless.org/tabbed/patches/clientnumber/tabbed-clientnumber-0.6.diff
  sudo wget https://tools.suckless.org/tabbed/patches/xft/tabbed-0.6-xft.diff
fi
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying clientnumber patch:\n\n"
sudo patch -p1 <patches/tabbed-clientnumber-0.6.diff
printf "\nApplying xft patch:\n\n"
sudo patch -p1 <patches/tabbed-0.6-xft.diff

printf "\nConfiguring patches\n\n"
sudo cp config.def.h config.h

sudo git add -A
sudo git commit -m "feat: setup my base tabbed version"
sudo make
sudo make clean install
