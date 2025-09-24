#!/bin/sh

if [ "$1" ]; then
  export SSL_NO_VERIFY_PEER=true
  env_vars='--preserve-env='
  env_vars="$env_vars"'SSL_NO_VERIFY_PEER,'
else
  env_vars=''
fi

dependencies="void-repo-nonfree"

if [ -n "$(find /sys/class/power_supply/ -name [bB][aA][tT]*)" ]; then
  printf "\nAdd tlp because batteries are detected:\n\n"
  dependencies="${dependencies} tlp"
fi

sudo $env_vars xbps-install -Sy $dependencies
