#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  export WGETRC="$(pwd)/.wgetrc"
  export CURL_HOME="$(pwd)"
  env_vars='--preserve-env='
  env_vars="$env_vars"'GIT_SSL_NO_VERIFY,'
  env_vars="$env_vars"'WGETRC,'
  env_vars="$env_vars"'CURL_HOME'
else
  env_vars=''
fi

printf "\nInstalling Linuxbrew.\n\n"

sudo useradd -r -m -s $(command -v nologin) -d /home/linuxbrew linuxbrew

sudo --preserve-env $env_vars -u linuxbrew \
  HOME=/home/linuxbrew NONINTERACTIVE=1 bash -c \
  "$(wget -O - https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo chmod -R o+rwx /home/linuxbrew

printf "\nSetting up Linuxbrew:\n\n"
brew_init='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
if ! grep -q "$brew_init" /etc/profile.d/*; then
  echo "$brew_init" >linuxbrew-initialisation.sh
  chmod o+rx linuxbrew-initialisation.sh
  sudo mv linuxbrew-initialisation.sh /etc/profile.d/
fi
