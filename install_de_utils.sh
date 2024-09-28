#!/bin/bash

# Installing other utilites of my desktop environment
printf "\nLastly installing the utilites of my desktop environment:\n\n"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install -Sy $(./parsedeps.sh de_util_deps.txt)

# Backup package managers.
printf "\nSetting up flatpak (needs reboot to work)\n\n"
sudo flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

printf "\nInstalling and setting up Linuxbrew\n\n"
bash -c \
  "$(wget -O - https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
brew_path_add='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
if ! grep -q "$brew_path_add" ~/.bash_profile; then
  printf "\n$brew_path_add\n" >>~/.bash_profile
fi

printf "\nInstall my dotfiles (with chezmoi)\n\n"
chezmoi init kalocsaibotond
