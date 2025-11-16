#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling xdeb\n\n"
sudo $env_vars git clone https://github.com/xdeb-org/xdeb
cd xdeb || return 1
sudo chmod o+rx xdeb
sudo ln -s $PWD/xdeb /usr/local/bin/xdeb

set_xdeb_pkgroot='export XDEB_PKGROOT=${HOME}/.config/xdeb'
if ! grep -q "$set_xdeb_pkgroot" /etc/profile.d/*; then
  echo "$set_xdeb_pkgroot" >set-xdeb-pkgroot.sh
  chmod o+rx set-xdeb-pkgroot.sh
  sudo mv set-xdeb-pkgroot.sh /etc/profile.d/
fi
