#!/bin/sh

if [ "$1" ]; then
  export SSL_NO_VERIFY_PEER=true
  env_vars='--preserve-env='
  env_vars="$env_vars"'SSL_NO_VERIFY_PEER,'
else
  env_vars=''
fi

dependencies="void-repo-nonfree"
pci_devices=$(lspci)
usb_devices=$(lsusb)

bluetooth_tools="bluez bluez-alsa"

if [ -n "$(find /sys/class/power_supply/ -name [bB][aA][tT]*)" ]; then
  printf "\nAdd tlp because batteries are detected:\n\n"
  dependencies="${dependencies} tlp"
fi

if [ -n "$(echo "$pci_devices\n$usb_devices" | grep -e 'BCM431[1-3]
BCM432[1-2]
BCM4322[4-5]
BCM4322[7-8]
BCM43142
BCM4331
BCM4352
BCM4360')" ]; then
  printf "\nAdd broadcom-wl-dkms because Broadcom cards are detected:\n\n"
  dependencies="${dependencies} broadcom-wl-dkms"
fi

if [ -n "$(echo "$pci_devices\n$usb_devices" | grep -e 'BCM2070[2-3]
BCM43142
BCM4335
BCM4350
BCM4356
BCM4371
BCM943142')" ]; then
  printf "\nAdd broadcom-bt-firmware, bluez because Broadcom cards are detected:\n\n"
  dependencies="${dependencies} broadcom-bt-firmware ${bluetooth_tools}"
fi

if [ -n "$(find /sys/class/bluetooth/ -name [hH][cH][iH]*)" ]; then
  printf "\nAdd bluez because bluetooth devices are detected:\n\n"
  dependencies="${dependencies} ${bluetooth_tools}"
fi

sudo $env_vars xbps-install -Sy $dependencies
