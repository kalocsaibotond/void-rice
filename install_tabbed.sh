#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  export WGETRC="$(pwd)/.wgetrc"
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY,WGETRC'
else
  env_vars=''
fi

printf "\nInstalling tabbed\n\n"
sudo $env_vars git clone https://git.suckless.org/tabbed
cd tabbed || return 1
sudo git checkout -b my_tabbed || return 1

printf "\nDownloading patches:\n\n"
sudo mkdir patches
cd patches
sudo $env_vars wget \
  https://tools.suckless.org/tabbed/patches/clientnumber/tabbed-clientnumber-0.6.diff
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying clientnumber patch:\n\n"
sudo patch -p1 <patches/tabbed-clientnumber-0.6.diff

printf "\nConfiguring patches\n\n"
sudo cp config.def.h config.h

sudo git add -A
sudo git commit -m "feat: setup my base tabbed version"
sudo make
sudo make clean install
