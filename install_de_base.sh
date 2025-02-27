#!/bin/sh

if [ "$1" ]; then
  export SSL_NO_VERIFY_PEER=true
  env_vars='--preserve-env=SSL_NO_VERIFY_PEER'
else
  env_vars=''
fi

printf "\nUpdating The system:\n\n"
sudo $env_vars xbps-install -Syy
sudo $env_vars xbps-install -u xbps
sudo $env_vars xbps-install -Syu

printf "\nInstalling base desktop environment dependencies:\n\n"
sudo $env_vars xbps-install -Sy $(./parsedeps.sh de_base_deps.txt)

sudo ln -sf $(xbps-query -f w3m-img | grep w3mimgdisplay) \
  /usr/local/bin/w3mimgdisplay

printf "\nConfiguring gpm to not start at boot:\n\n"
# Configuring gpm
sudo touch /etc/sv/gpm/down # I dont want it to start at boot
sudo ln -sf /etc/sv/gpm /var/service

printf "\nConfiguring fontconfig:\n\n"
sudo ln -sf /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf \
  /etc/fonts/conf.d/
sudo xbps-reconfigure -f fontconfig

printf "\nConfiguring git:\n\n"
sudo git config --global user.email "kalocsaibotond@gmail.com"
sudo git config --global user.name "Botond Kalocsai"

./install_dwm.sh $1
./install_slstatus.sh $1
./install_st.sh $1
./install_devour.sh $1
./install_sfm.sh $1
./install_tabbed.sh $1
./install_surf.sh $1

printf "\nSetting up global xinitrc\n\n"

set_xkbmap="setxkbmap hu"
if ! grep -q "$set_xkbmap" /etc/X11/xinit/xinitrc.d/*; then
  echo "$set_xkbmap" >90-set-xkbmap.sh
  chmod o+rx 90-set-xkbmap.sh
  sudo mkdir -p /etc/X11/xinit/xinitrc.d/
  sudo mv 90-set-xkbmap.sh /etc/X11/xinit/xinitrc.d/
fi

suckless_xinitrc="slstatus & exec dwm"
if ! grep -q "$suckless_xinitrc" /etc/X11/xinit/xinitrc.d/*; then
  echo "$suckless_xinitrc" >99-suckless-xinitrc.sh
  chmod o+rx 99-suckless-xinitrc.sh
  sudo mkdir -p /etc/X11/xinit/xinitrc.d/
  sudo mv 99-suckless-xinitrc.sh /etc/X11/xinit/xinitrc.d/
fi

echo 'set number
/twm/,$ delete
xit' | sudo ex /etc/X11/xinit/xinitrc # Cleaning global xinitrc up

printf "\nSetting up POSIX shell system-wide config into /etc/shrc .\n\n"

sys_shrc='# Only apply in interactive shell sessions
case $- in
*i*) ;; # Interactive shell session
*) return ;;
esac

if [ -d /etc/shrc.d ]; then
  for f in /etc/shrc.d/*.sh; do
    [ -r "$f" ] && . "$f"
  done
  unset f
fi'
if ! [ -f /etc/shrc ] || ! grep -q "$sys_shrc" /etc/shrc; then
  echo '#!/bin/sh
# /etc/shrc

# Do not edit this file.
# Place your readable configs in /etc/shrc.d/*.sh

' >shrc
  echo sys_shrc >>shrc
  chmod o+rx shrc
  sudo mv shrc /etc/
fi
sudo mkdir -p /etc/shrc.d

set_shell_name='export SHELL_NAME=$(ps -p $$ -o comm=)'
if ! grep -q "$set_shell_name" /etc/shrc.d/*; then
  echo "$set_shell_name" >00-set-shell-name.sh
  chmod o+rx 00-set-shell-name.sh
  sudo mv 00-set-shell-name.sh /etc/shrc.d/
fi

set_env='export ENV=/etc/shrc'
sudo mkdir -p /etc/profile.d/
if ! grep -q "$set_env" /etc/profile.d/*; then
  echo "$set_env" >00-set-env.sh
  chmod o+rx 00-set-env.sh
  sudo mv 00-set-env.sh /etc/profile.d/
fi

# Source POSIX shell configuration in bashrc
source_env='[ -f "$ENV" ] && . $ENV'
sudo mkdir -p /etc/bash/bashrc.d/
if ! grep -q "$source_env" /etc/bash/bashrc.d/*; then
  echo "$source_env" >00-source-env.sh
  chmod o+rx 00-source-env.sh
  sudo mv 00-source-env.sh /etc/bash/bashrc.d/
fi
