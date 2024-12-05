#!/bin/sh

printf "\nInstalling slstatus\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/slstatus
cd slstatus
sudo git checkout -b my_slstatus

printf "\nConfiguring slstatus\n\n"
sudo cp config.def.h config.h

sudo sed -i "s/\\([^{]\\+\\){ datetime,.\\+/"$(
)"\\1{ battery_perc, \"bat: %s\",\\t\"BAT0\" },"$(
)"\\n\\1{ keymap, \" kb: %s\",\\tNULL },"$(
)"\\n\\1{ datetime, \" %s\",\\t\"%F %T\" },/" config.h

sudo git add ./config.h
sudo git commit -m "feat: setup my base slstatus version"
sudo make
sudo make clean install
