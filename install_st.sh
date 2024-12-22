#!/bin/sh

printf "\nInstalling st\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/st
cd st
sudo git checkout -b my_st

printf "\nDownloading patches:\n\n"
sudo mkdir patches
cd patches
sudo cp ../../local_patches/st/charpropoffsets/st-charpropoffsets-with-wide-glyph-support-20240927-0.9.2.diff .
if [ true = "$1" ]; then # Downloading patches without SSL check
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/font2/st-font2-0.8.5.diff
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-boxdraw-20220411-ef05519.diff
  sudo wget --no-check-certificate \
    https://st.suckless.org/patches/w3m/st-w3m-0.8.3.diff
else
  sudo wget https://st.suckless.org/patches/font2/st-font2-0.8.5.diff
  sudo wget https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff
  sudo wget https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-boxdraw-20220411-ef05519.diff
  sudo wget https://st.suckless.org/patches/w3m/st-w3m-0.8.3.diff
fi
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying font2 patch:\n\n"
sudo git apply patches/st-font2-0.8.5.diff
printf "\nApplying boxdraw patch:\n\n"
sudo patch -p1 <patches/st-boxdraw_v2-0.8.5.diff
printf "\nApplying glyph wide support patch:\n\n"
sudo git apply patches/st-glyph-wide-support-boxdraw-20220411-ef05519.diff
printf "\nApplying local charpropoffsets patch:\n\n"
sudo git apply patches/st-charpropoffsets-with-wide-glyph-support-20240927-0.9.2.diff
printf "\nApplying w3m patch:\n\n"
sudo patch -p1 <patches/st-w3m-0.8.3.diff

printf "\nConfiguring patches\n\n"
sudo cp config.def.h config.h

echo 'set number
/font =
.,. s/=[^"]*"[^"]\{1,\}";/= '$(
)'"OpenDyslexicMono:pixelsize=12:antialias=true:autohint=true";/
/font2\[\] =
+
.,/};/- change
	"Noto Color Emoji:pixelsize=12:antialias=true:autohint=true"
	"Symbols Nerd Font Mono:pixelsize=12:antialias=true:autohint=true"
.
/chscale =
.,. s/=[^=]\{1,\};/= 3.0 \/ 2.0;/
/cypropoffset =
.,. s/=[^=]\{1,\};/= 1.0 \/ 3.0;/
/boxdraw =
.,. s/=[^=]\{1,\};/= 1;/
/boxdraw_bold =
.,. s/=[^=]\{1,\};/= 1;/
/boxdraw_braille =
.,. s/=[^=]\{1,\};/= 1;/
xit' | sudo ex config.h

sudo git add -A
sudo git commit -m "feat: setup my base st version"
sudo make
sudo make clean install
