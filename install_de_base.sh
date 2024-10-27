#!/bin/bash

printf "\nUpdating The system:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syy
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -u xbps
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Syu

printf "\nInstalling base desktop environment dependencies:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_base_deps.txt)

printf "\nConfiguring fontconfig:\n\n"
sudo ln -sf /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf \
  /etc/fonts/conf.d/
sudo xbps-reconfigure -f fontconfig

printf "\nConfiguring git:\n\n"
sudo git config --global user.email "kalocsaibotond@gmail.com"
sudo git config --global user.name "Botond Kalocsai"

printf "\nConfiguring gpm to not start at boot:\n\n"
# Configuring gpm
sudo touch /etc/sv/gpm/down # I dont want it to start at boot
sudo ln -sf /etc/sv/gpm /var/service

./install_dwm.sh $1
./install_st.sh $1
./install_devour.sh $1
./install_tabbed.sh $1
./install_surf.sh $1

printf "\nSetting up global xinitrc\n\n"
suckless_xinitrc="setxkbmap hu & slstatus & exec dwm"
if ! grep -q "$suckless_xinitrc" /etc/X11/xinit/xinitrc.d/*; then
  echo "$suckless_xinitrc" >99-suckless-xinitrc.sh
  chmod o+rx 99-suckless-xinitrc.sh
  sudo mkdir -p /etc/X11/xinit/xinitrc.d/
  sudo mv 99-suckless-xinitrc.sh /etc/X11/xinit/xinitrc.d/
fi
sudo sed -z -i 's/twm.*//' /etc/X11/xinit/xinitrc # Cleaning global xinitrc up

printf "\nSetting up POSIX shell system-wide config into /etc/sh/shrc .\n\n"
sys_shrc='for f in /etc/shrc.d/*.sh; do [ -r $f ] && . $f; done; unset f'
if ! [ -f /etc/shrc ] || ! grep -q "$sys_shrc" /etc/shrc; then
  echo '#!/bin/sh' >shrc
  echo '# /etc/shrc' >>shrc
  printf '\n# Do not edit this file.'$(
  )'\n# Place your readable configs in /etc/shrc.d/*.sh .\n\n' >>shrc
  echo 'if [ -d /etc/shrc.d ]; then' >>shrc
  echo "	$sys_shrc" >>shrc
  echo 'fi' >>shrc
  chmod o+rx shrc
  sudo mv shrc /etc/
fi
sudo mkdir -p /etc/shrc.d

set_env='export ENV=/etc/shrc'
sudo mkdir -p /etc/profile.d/
if ! grep -q "$set_env" /etc/profile.d/*; then
  echo "$set_env" >00-set_env.sh
  chmod o+rx 00-set_env.sh
  sudo mv 00-set_env.sh /etc/profile.d/
fi

# Source POSIX shell configuration in bashrc
source_env='[ -f "$ENV" ] && . $ENV'
sudo mkdir -p /etc/bash/bashrc.d/
if ! grep -q "$source_env" /etc/bash/bashrc.d/*; then
  echo "$source_env" >00-source_env.sh
  chmod o+rx 00-source_env.sh
  sudo mv 00-source_env.sh /etc/bash/bashrc.d/
fi
