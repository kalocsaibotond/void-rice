#!/bin/bash

printf "\nInstalling slstatus\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/slstatus
cd slstatus
sudo git checkout -b my_slstatus

printf "\nConfiguring slstatus\n\n"
sudo cp config.def.h config.h

sed -i "s/\\([^{]\\+\\){ datetime, \"%s\",\\([^\"]\\+\\).\\+/"$(
)"\\1{ battery_perc, \"bat: %s\",\\2\"BAT0\" },"$(
)"\\n\\1{ keymap, \" kb: %s\",\\2NULL },"$(
)"\\n\\1{ datetime, \" %s\",\\2\"%F %T\" },/"

sudo git add ./config.h
sudo git commit -m "feat: setup my base slstatus version"
sudo make
sudo make clean install
