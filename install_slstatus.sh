#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling slstatus\n\n"
sudo $env_vars git clone https://git.suckless.org/slstatus
cd slstatus || return 1
sudo git checkout -b my_slstatus || return 1

printf "\nConfiguring slstatus\n\n"
sudo cp config.def.h config.h

# Optional status line part.
slstatus_line="\n"

# Search for ASUS fan boost mode:
asus_fan_file="/sys/devices/platform/asus-nb-wmi/fan_boost_mode"
if [ -r "$asus_fan_file" ]; then
  slstatus_line="$slstatus_line	{ cat,"
  slstatus_line="$slstatus_line \"Fan mode: %s, \","
  slstatus_line="$slstatus_line \"$asus_fan_file\"  },\n"
fi

# Search for batteries:
for battery in /sys/class/power_supply/[bB][aA][tT]*; do
  battery=$(basename $battery)
  echo "Found battery: $battery"
  slstatus_line="$slstatus_line	{ battery_perc,"
  slstatus_line="$slstatus_line \"$battery: %s%%, \","
  slstatus_line="$slstatus_line \"$battery\"  },\n"
done

echo 'set number
/function format
+
.,. change'"$slstatus_line"'	{ keymap,       "kb: %s, ",     NULL    },
	{ datetime,     "%s",           "%F %T" },
.
xit' | sudo ex config.h

sudo git add ./config.h
sudo git commit -m "feat: setup my base slstatus version"
sudo make
sudo make clean install
