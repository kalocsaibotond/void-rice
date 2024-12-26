#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling dwm\n\n"
sudo $env_vars git clone https://git.suckless.org/dwm
cd dwm || return 1
sudo git checkout -b my_dwm || return 1

printf "\nConfiguring dwm\n\n"
sudo cp config.def.h config.h

echo 'set number
/class \{1,\}instance
+
.,/};/- change
	{ NULL,       NULL,       NULL,       0,            False,       -1 },
.
/#define MODKEY
.,. s/MODKEY[ a-zA-Z0-9]*/MODKEY Mod4Mask/
xit' | sudo ex config.h

sudo git add ./config.h
sudo git commit -m "feat: setup my base dwm version"
sudo make
sudo make clean install
