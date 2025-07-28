#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling nnn.\n\n"
sudo $env_vars git clone https://github.com/jarun/nnn.git
cd nnn || return 1

set_nnn_fifo='export NNN_FIFO=/tmp/nnn.fifo'
if ! grep -q "$set_nnn_fifo" /etc/profile.d/*; then
  echo "$set_nnn_fifo" >set-nnn-fifo.sh
  chmod o+rx set-nnn-fifo.sh
  sudo mv set-nnn-fifo.sh /etc/profile.d/
fi

set_nnn_sel='export NNN_SEL=/tmp/.sel'
if ! grep -q "$set_nnn_sel" /etc/profile.d/*; then
  echo "$set_nnn_sel" >set-nnn-sel.sh
  chmod o+rx set-nnn-sel.sh
  sudo mv set-nnn-sel.sh /etc/profile.d/
fi

set_nnn_locker='export NNN_LOCKER=physlock'
if ! grep -q "$set_nnn_locker" /etc/profile.d/*; then
  echo "$set_nnn_locker" >set-nnn-locker.sh
  chmod o+rx set-nnn-locker.sh
  sudo mv set-nnn-locker.sh /etc/profile.d/
fi

set_nnn_opener='export NNN_OPENER=opener'
if ! grep -q "$set_nnn_opener" /etc/profile.d/*; then
  echo "$set_nnn_opener" >set-nnn-opener.sh
  chmod o+rx set-nnn-opener.sh
  sudo mv set-nnn-opener.sh /etc/profile.d/
fi

sudo chmod o+rx ./plugins/*

sudo make O_NERD=1 install
