#!/bin/sh

if [ "$1" ]; then
  export SSL_NO_VERIFY_PEER=true
  export GIT_SSL_NO_VERIFY=true
  export WGETRC="$(pwd)/.wgetrc"
  export CURL_HOME="$(pwd)"
  env_vars='--preserve-env='
  env_vars="$env_vars"'SSL_NO_VERIFY_PEER,'
  env_vars="$env_vars"'GIT_SSL_NO_VERIFY,'
  env_vars="$env_vars"'WGETRC,'
  env_vars="$env_vars"'CURL_HOME'
else
  env_vars=''
fi

#######################################################################
printf "\nIinstalling general utilites of the desktop environment:\n\n"
#######################################################################
sudo $env_vars xbps-install -Sy $(./parsedeps.sh de_util_deps.txt)

./install_nnn.sh $1

./set_up_iwd.sh

##############################
printf "\nSetting up TLP.\n\n"
##############################
sudo ln -sf /etc/sv/tlp /var/service # I usually work on laptops.

###############################
printf "\nSetting up CUPS.\n\n"
###############################
sudo touch /etc/sv/cupsd/down # Rarely, I have to print documents.
sudo ln -sf /etc/sv/cupsd /var/service

########################################
printf "\nSet XDG default applications."
########################################
sudo ln -sf $(pwd)/mimeapps.list /etc/xdg

#########################################################
printf "\nSetting up flatpak (needs reboot to work).\n\n"
#########################################################
sudo $env_vars flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

#################################
printf "\nSetting up Zoxide.\n\n"
#################################
zoxide_init='case $SHELL_NAME in
"zsh") eval "$(zoxide init zsh --hook prompt)" ;;
"bash") eval "$(zoxide init bash --hook prompt)" ;;
"ksh") eval "$(zoxide init ksh --hook prompt)" ;;
"mksh") eval "$(zoxide init ksh --hook prompt)" ;;
"oksh") eval "$(zoxide init ksh --hook prompt)" ;;
*) eval "$(zoxide init posix --hook prompt)" ;;
esac'
if ! grep -q "$zoxide_init" /etc/shrc.d/*; then
  echo "$zoxide_init" >99-zoxide-initialisation.sh
  chmod o+rx 99-zoxide-initialisation.sh
  sudo mv 99-zoxide-initialisation.sh /etc/shrc.d/
fi

#################################
printf "\nSetting up Neovim:\n\n"
#################################
sudo npm install -g neovim # The main text editor of my system.

####################################################
printf "\nInstalling my dotfiles (with Chezmoi):\n\n"
####################################################
chezmoi init kalocsaibotond
