#!/bin/bash

# Installing other utilites of my desktop environment
printf "\nLastly installing the utilites of my desktop environment:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_util_deps.txt)

# Backup package managers.
printf "\nInstalling Linuxbrew\n\n"
if [ true = "$1" ]; then # Downloading patches without SSL check
  bash -c \
    "$(wget --no-check-certificate -O \
      - https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
else
  bash -c \
    "$(wget -O - https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
fi

printf "\nSetting up flatpak (needs reboot to work)\n\n"
sudo flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

printf "\nSetting up Linuxbrew\n\n"
brew_init='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
if ! grep -q "$brew_init" /etc/profile.d/*; then
  echo "$brew_init" >linuxbrew.sh
  chmod o+rx linuxbrew.sh
  sudo mv linuxbrew.sh /etc/profile.d/
fi

printf "\nSetting up Zoxide\n\n"
zoxide_init='eval "$(zoxide init bash)"'
if ! grep -q "$zoxide_init" /etc/bash/bashrc.d/*; then
  echo "$zoxide_init" >zoxide.sh
  chmod o+rx zoxide.sh
  sudo mv zoxide.sh /etc/bash/bashrc.d/
fi

printf "\nInstall my dotfiles (with chezmoi)\n\n"
chezmoi init kalocsaibotond
