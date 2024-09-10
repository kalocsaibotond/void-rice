#!/bin/bash

printf "\nInstalling st\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/st
cd st
sudo git checkout -b my_st

printf "\nDownloading patches:\n\n"
sudo mkdir patches
cd patches
if [ true = "$1" ]; then # Downloading patches without SSL check
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/font2/st-font2-0.8.5.diff
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-boxdraw-20220411-ef05519.diff
else
  sudo wget https://st.suckless.org/patches/font2/st-font2-0.8.5.diff
  sudo wget https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff
  sudo wget https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-boxdraw-20220411-ef05519.diff
fi
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying font2 patch:\n\n"
sudo git apply patches/st-font2-0.8.5.diff
printf "\nApplying boxdraw patch:\n\n"
sudo patch -p1 <patches/st-boxdraw_v2-0.8.5.diff
printf "\nApplying glyph wide support patch:\n\n"
sudo git apply patches/st-glyph-wide-support-boxdraw-20220411-ef05519.diff

printf "\nConfiguring patches\n\n"
sudo cp config.def.h config.h

printf "\nConfiguring font2 patch:\n\n"
sudo sed -i 's/Liberation Mono/OpenDyslexicMono/' config.h
sudo sed -i 's/^.\+Inconsolata for Powerline.\+$/'$(
)'\t"Noto Color Emoji:pixelsize=11:antialias=true:autohint=true",/' \
  config.h
sudo sed -i 's/^.\+Hack Nerd Font Mono.\+$/'$(
)'\t"Symbols Nerd Font Mono:pixelsize=11:antialias=true:autohint=true",/' \
  config.h

printf "\nConfiguring boxdraw patch:\n\n"
sudo sed -i 's/boxdraw = 0/boxdraw = 1/' config.h
sudo sed -i 's/boxdraw_bold = 0/boxdraw_bold = 1/' config.h
sudo sed -i 's/boxdraw_braille = 0/boxdraw_braille = 1/' config.h

sudo git add -A
sudo git commit -m "feat: setup my base st version"
sudo make
sudo make clean install
