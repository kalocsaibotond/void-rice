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
if ! grep -F -q "$set_nnn_fifo" /etc/profile.d/*; then
  echo "$set_nnn_fifo" >set-nnn-fifo.sh
  chmod o+rx set-nnn-fifo.sh
  sudo mv set-nnn-fifo.sh /etc/profile.d/
fi

set_nnn_sel='export NNN_SEL=/tmp/.sel'
if ! grep -F -q "$set_nnn_sel" /etc/profile.d/*; then
  echo "$set_nnn_sel" >set-nnn-sel.sh
  chmod o+rx set-nnn-sel.sh
  sudo mv set-nnn-sel.sh /etc/profile.d/
fi

set_nnn_locker='export NNN_LOCKER=physlock'
if ! grep -F -q "$set_nnn_locker" /etc/profile.d/*; then
  echo "$set_nnn_locker" >set-nnn-locker.sh
  chmod o+rx set-nnn-locker.sh
  sudo mv set-nnn-locker.sh /etc/profile.d/
fi

set_nnn_opener='export NNN_OPENER=opener'
if ! grep -F -q "$set_nnn_opener" /etc/profile.d/*; then
  echo "$set_nnn_opener" >set-nnn-opener.sh
  chmod o+rx set-nnn-opener.sh
  sudo mv set-nnn-opener.sh /etc/profile.d/
fi

# NOTE: Since nnn only allow user level configuration, we create a symbolic
# link in each user home directory to the official plugin folder of nnn
# repository. To prevent collusion with user plugins, the official plugins are
# available in a subfolder-like symbolic link named official. The official
# subfolder symbolic link is in the default plugin location.
sudo chmod -R o+rx ./plugins/*
sudo mkdir -p /etc/skel/.config/nnn/plugins
sudo ln -sf $PWD/plugins /etc/skel/.config/nnn/plugins/official
user_homedirs=$(awk -F : '( 1000 <= $3 ){ print $6 }' /etc/passwd)
for user_homedir in $user_homedirs; do
  sudo ln -sf $PWD/plugins $user_homedir/.config/nnn/plugins/official
done

sudo make O_NERD=1 install
