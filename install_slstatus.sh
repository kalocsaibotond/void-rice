#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling slstatus\n\n"
sudo $env_vars git clone https://git.suckless.org/slstatus
cd slstatus || return 1
sudo git checkout -b my_slstatus || return 1

printf "\nConfiguring slstatus\n\n"
sudo cp config.def.h config.h

echo 'set number
/function format
+
.,. change
	{ battery_perc, "bat: %s%%,",   "BAT1" },
	{ keymap, " kb: %s,",         NULL },
	{ datetime, " %s",            "%F %T" },
.
xit' | sudo ex config.h

sudo git add ./config.h
sudo git commit -m "feat: setup my base slstatus version"
sudo make
sudo make clean install
