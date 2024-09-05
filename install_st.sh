#!/bin/bash

# dwm is installed into opt
cd /opt

echo "Installing st"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/st
cd st
sudo git checkout -b my_st

# Patching
sudo mkdir patches
if [ true = "$1" ]; then # Downloading patches
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/font2/st-font2-0.8.5.diff
else
  sudo wget https://st.suckless.org/patches/font2/st-font2-0.8.5.diff
fi
sudo git apply patches/st-font2-0.8.5.diff

sudo git add -A
sudo git commit -m "feat: setup my base st version"
sudo make
sudo make clean install
