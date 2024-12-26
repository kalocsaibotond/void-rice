#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling devour\n\n"
sudo $env_vars git clone https://github.com/salman-abedin/devour
cd devour || return 1
sudo git checkout -b my_devour || return 1

printf "\nFetch local shellalias patch:\n\n"
sudo mkdir patches
cd patches
sudo cp ../../local_patches/devour/shellalias/devour-shellalias-20241215-3184e2a.diff .
cd ..

printf "\nApplying local shellalias patch:\n\n"
sudo git apply patches/devour-shellalias-20241215-3184e2a.diff

sudo git add -A
sudo git commit -m "feat: setup my base devour version"
sudo make install
