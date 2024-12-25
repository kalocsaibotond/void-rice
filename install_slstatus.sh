#!/bin/sh

printf "\nInstalling slstatus\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/slstatus
cd slstatus || return 1
sudo git checkout -b my_slstatus || return 1

printf "\nConfiguring slstatus\n\n"
sudo cp config.def.h config.h

echo 'set number
/function format
+
.,. change
	{ battery_perc, "bat: %s,",   "BAT0" },
	{ keymap, " kb: %s,",         NULL },
	{ datetime, " %s",            "%F %T" },
.
xit' | sudo ex config.h

sudo git add ./config.h
sudo git commit -m "feat: setup my base slstatus version"
sudo make
sudo make clean install
