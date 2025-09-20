#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling hkd\n\n"
sudo $env_vars git clone https://github.com/aaronamk/hkd.git
cd hkd || return 1
sudo git checkout -b my_hkd || return 1

printf "\nConfiguring hkd\n\n"
sudo cp config.h config.def.h

echo 'set number
/pulseaudio/ s/pulseaudio/alsa/

/vol_up/,/mute/ change
static const char *vol_up[] = { "amixer", "set", "Master", "2%+", NULL };
static const char *vol_down[] = { "amixer", "set", "Master", "2%-", NULL };
static const char *vol_toggle_mute[] = { "amixer", "set", "Master", "toggle", NULL };
.

/term/-,/shutdown/ delete

/term/,/shutdown/ delete

xit' | sudo ex config.h

sudo git add -A
sudo git commit -m "feat: setup my base hkd version"
sudo make install

printf "\nMaking runit service from hkd and configure it.\n\n"

if ! [ -d /etc/sv/hkd ]; then
  echo '#!/bin/sh
keyboards=$(find /dev/input/by-path/ -name "*kbd*" | tr "\n" " ")
exec /usr/local/bin/hkd $keyboards > /dev/null' >run
  chmod o+rx run
  sudo mkdir -p /etc/sv/hkd
  sudo mv run /etc/sv/hkd/
fi

sudo ln -sf /etc/sv/hkd /var/service
