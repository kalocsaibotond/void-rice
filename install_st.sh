#!/bin/bash

# dwm is installed into opt
cd /opt

echo "Installing st"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/st
cd st
sudo git checkout -b my_st

# Downloading patches
sudo mkdir patches
cd patches
if [ true = "$1" ]; then # Downloading patches
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff
else
  sudo wget https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff
fi
cd ..

# Applying and configuring boxdraw patch
sudo patch -p1 <patches/st-boxdraw_v2-0.8.5.diff
sudo cp config.def.h config.h
sudo sed -i 's/boxdraw = 0/boxdraw = 1/' config.h
sudo sed -i 's/boxdraw_bold = 0/boxdraw_bold = 1/' config.h
sudo sed -i 's/boxdraw_braille = 0/boxdraw_braille = 1/' config.h

sudo git add -A
sudo git commit -m "feat: setup my base st version"
sudo make
sudo make clean install
