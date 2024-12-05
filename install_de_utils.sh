#!/bin/sh

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
  echo "$brew_init" >linuxbrew_init.sh
  chmod o+rx linuxbrew_init.sh
  sudo mv linuxbrew_init.sh /etc/profile.d/
fi

printf "\nSetting up TLP\n\n"
sudo ln -sf /etc/sv/tlp /var/service

printf "\nSetting up CUPS\n\n"
sudo touch /etc/sv/cupsd/down # I dont want it to start at boot
sudo ln -sf /etc/sv/cupsd /var/service

printf "\nSetting up Zoxide\n\n"
zoxide_init='case $SHELL_NAME in
"zsh") eval "$(zoxide init zsh --hook prompt)" ;;
"bash") eval "$(zoxide init bash --hook prompt)" ;;
"ksh") eval "$(zoxide init ksh --hook prompt)" ;;
"mksh") eval "$(zoxide init ksh --hook prompt)" ;;
"oksh") eval "$(zoxide init ksh --hook prompt)" ;;
*) eval "$(zoxide init posix --hook prompt)" ;;
esac'
if ! grep -q "$zoxide_init" /etc/shrc.d/*; then
  echo "$zoxide_init" >zoxide_init.sh
  chmod o+rx zoxide_init.sh
  sudo mv zoxide_init.sh /etc/shrc.d/
fi

printf "\nSetting up Neovim\n\n"
sudo npm install -g neovim

printf "\nInstall my dotfiles (with chezmoi)\n\n"
chezmoi init kalocsaibotond
