#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling sfm\n\n"
sudo $env_vars git clone https://github.com/afify/sfm.git
cd sfm || return 1
sudo git checkout -b my_sfm || return 1

printf "\nConfiguring sfm\n\n"
sudo cp config.def.h config.h

sudo git add -A
sudo git commit -m "feat: setup my base sfm version"
sudo make
sudo make install
