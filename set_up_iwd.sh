#!/bin/sh

printf "\nSetting up IWD.\n\n"

if ! xbps-query -S iwd >/dev/null; then
  echo "IWD is not installed, aborting set up process."
  return 1
fi

sudo rm /var/service/wpa_supplicant
sudo ln -sf /etc/sv/dbus /var/service
sudo ln -sf /etc/sv/iwd /var/service

# FIX: As of iwd 3.10 and dhcpcd 10.1, iwd, for some reason, communication do
# not occur between them upon wifi network switching.
# Thus the internet is not avaliable until manually running `dhcpcd -n` or
# restating dhcpcd (or iwd). To circumwent this, we use iwd-s dhcp client
# that only handles the wifi and restrict dhcpcd to not handle wifi.

# Setting up iwd's dhcp client.
if [ -f /etc/iwd/main.conf ]; then
  if ! $(cat /etc/iwd/main.conf | tr "\n" "\t" |
    grep -q '\[General\]	[^][]*EnableNetworkConfiguration=true'); then

    if grep -q '\[General\]' /etc/iwd/main.conf; then
      echo 'set number
% global/EnableNetworkConfiguration/delete
/\[General\]/ append
EnableNetworkConfiguration=true
.
xit' | sudo ex /etc/iwd/main.conf
    else
      echo 'set number
$ append

[General]
EnableNetworkConfiguration=true
.
1,$-1 global/EnableNetworkConfiguration/delete
xit' | sudo ex /etc/iwd/main.conf
    fi

    sudo chmod o+rx /etc/iwd/main.conf
  fi

else
  sudo mkdir -p /etc/iwd/
  echo '[General]
EnableNetworkConfiguration=true' >./main.conf
  chmod o+rx main.conf
  sudo mv main.conf /etc/iwd/
fi

# Restricting dhcpcd to not handle the wifi interfaces.
if ! grep -q 'denyinterfaces wl\*$' /etc/dhcpcd.conf; then
  echo 'set number
$ append

# We restrict dhcpcd to not handle the wifi interfaces, since iwd is configured
# to iwd handles them.
denyinterfaces wl*
.
xit' | sudo ex /etc/dhcpcd.conf
  sudo chmod o+rx /etc/dhcpcd.conf
fi
