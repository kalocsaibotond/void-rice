#!/bin/sh

if [ "$1" ]; then
  export SSL_NO_VERIFY_PEER=true
  env_vars='--preserve-env=SSL_NO_VERIFY_PEER'
else
  env_vars=''
fi

###################################
printf "\nUpdating The system:\n\n"
###################################
sudo $env_vars xbps-install -Syy
sudo $env_vars xbps-install -u xbps
sudo $env_vars xbps-install -Syu

################################################################
printf "\nInstalling base desktop environment dependencies:\n\n"
################################################################
sudo $env_vars xbps-install -Sy $(./parsedeps.sh de_base_deps.txt)
sudo ln -sf $(xbps-query -f w3m-img | grep w3mimgdisplay) \
  /usr/local/bin

#########################################
printf "\nInstalling system-wide opener."
#########################################
sudo ln -sf $(pwd)/opener.sh /usr/local/bin/opener

#####################################################################
printf "\nConfiguring git globally with my credentials for root:\n\n"
#####################################################################
sudo git config --global user.email "kalocsaibotond@gmail.com"
sudo git config --global user.name "Botond Kalocsai"

##############################################################################
printf "\nSystem-wide, from source, local installation of basic utilites:\n\n"
##############################################################################
# Graphical utilities
./install_dwm.sh $1
./install_slstatus.sh $1
./install_st.sh $1
./install_devour.sh $1
./install_tabbed.sh $1
./install_surf.sh $1

# Console utilites
./install_sfm.sh $1

##########################################################
printf "\nSetting up, system-wide Xorg configuration:\n\n"
##########################################################

printf "\nSetting Xorg keyboard config and Esc - Caps Lock swap.\n\n"
xorg_keyboard_config='
Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "hu"
  Option "XkbOptions" "caps:swapescape"
EndSection
' # I usually work on hungarian keyboards with esc - caps lock swapped.
if ! grep -q '"XkbLayout"' /etc/X11/xorg.conf.d/*; then
  echo "$xorg_keyboard_config" >00-keyboard.conf
  chmod o+rx 00-keyboard.conf
  sudo mkdir -p /etc/X11/xorg.conf.d/
  sudo mv 00-keyboard.conf /etc/X11/xorg.conf.d/
fi

printf "\nSetting up xinitrc to run dwm and slstatus upon calling startx.\n\n"
suckless_xinitrc="slstatus & exec dwm"
if ! grep -q "$suckless_xinitrc" /etc/X11/xinit/xinitrc.d/*; then
  echo "$suckless_xinitrc" >99-suckless-xinitrc.sh
  chmod o+rx 99-suckless-xinitrc.sh
  sudo mkdir -p /etc/X11/xinit/xinitrc.d/
  sudo mv 99-suckless-xinitrc.sh /etc/X11/xinit/xinitrc.d/
fi

printf "\nDelete spurious xinitrc file content.\n\n"
echo 'set number
/twm/,$ delete
xit' | sudo ex /etc/X11/xinit/xinitrc # Cleaning global xinitrc up

######################################################################
printf "\nSetting up console and shell system-wide configuration.\n\n"
######################################################################

printf "\nSetting up Esc - Caps Lock swap on console:\n\n"
if ! grep -q "loadkeys /etc/swap_esc_capslock\.kmap" /etc/rc.local; then
  dumpkeys >swap_esc_capslock.kmap
  echo 'set extended
set number
% global!/^keycode.*(Escape|Caps_Lock)/d
% s/Caps_Lock/caps/
% s/Escape/Caps_Lock/
% s/caps/Escape/
xit' | sudo ex swap_esc_capslock.kmap
  chmod o+rx swap_esc_capslock.kmap
  sudo mv swap_esc_capslock.kmap /etc/
  echo 'set number
$
append

loadkeys /etc/swap_esc_capslock.kmap
.
xit' | sudo ex /etc/rc.local
fi

printf "\nConfiguring gpm to not start at boot:\n\n"
sudo touch /etc/sv/gpm/down # I dont want it to start at boot
sudo ln -sf /etc/sv/gpm /var/service

printf "\nSetting up interactive POSIX shell startup file /etc/shrc .\n\n"
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

printf "\nSetting POSIX shell ENV environment variable to /etc/profile .\n\n"
set_env='export ENV=/etc/shrc'
sudo mkdir -p /etc/profile.d/
if ! grep -q "$set_env" /etc/profile.d/*; then
  echo "$set_env" >00-set-env.sh
  chmod o+rx 00-set-env.sh
  sudo mv 00-set-env.sh /etc/profile.d/
fi

printf "\nSetting up POSIX shell SHELL_NAME environment variable.\n\n"
set_shell_name='export SHELL_NAME=$(ps -p $$ -o comm=)'
if ! grep -q "$set_shell_name" /etc/shrc.d/*; then
  echo "$set_shell_name" >00-set-shell-name.sh
  chmod o+rx 00-set-shell-name.sh
  sudo mv 00-set-shell-name.sh /etc/shrc.d/
fi

printf "\nSetting up POSIX shell GPG_TTY environment variable.\n\n"
set_gpg_tty='export GPG_TTY=$(tty)'
if ! grep -q "$set_gpg_tty" /etc/shrc.d/*; then
  echo "$set_gpg_tty" >10-set-gpg-tty.sh
  chmod o+rx 10-set-gpg-tty.sh
  sudo mv 10-set-gpg-tty.sh /etc/shrc.d/
fi

printf "\nSetting up Bash to source the value of ENV environment variable.\n\n"
# Source POSIX shell configuration in bashrc
source_env='[ -f "$ENV" ] && . $ENV'
sudo mkdir -p /etc/bash/bashrc.d/
if ! grep -q "$source_env" /etc/bash/bashrc.d/*; then
  echo "$source_env" >00-source-env.sh
  chmod o+rx 00-source-env.sh
  sudo mv 00-source-env.sh /etc/bash/bashrc.d/
fi

############################################################
printf "\nConfiguring fontconfig for nerd font symbols:\n\n"
############################################################
sudo ln -sf /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf \
  /etc/fonts/conf.d
sudo xbps-reconfigure -f fontconfig
