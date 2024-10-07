#!/bin/bash

printf "\nInstalling surf\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/surf
cd surf
sudo git checkout -b my_surf

printf "\nDownloading patches:\n\n"
sudo mkdir patches
cd patches
if [ true = "$1" ]; then # Downloading patches without SSL check
  sudo wget --no-check-certificate \
    https://surf.suckless.org/patches/modal/surf-modal-20190209-d068a38.diff
  sudo wget --no-check-certificate \
    https://surf.suckless.org/patches/clipboard-instead-of-primary/surf-clipboard-20200112-a6a8878.diff
  sudo wget --no-check-certificate \
    https://surf.suckless.org/patches/startgo/surf-startgo-20200913-d068a38.diff
  sudo wget --no-check-certificate \
    https://surf.suckless.org/patches/searchengines/surf-searchengines-20220804-609ea1c.diff
else
  sudo wget https://surf.suckless.org/patches/modal/surf-modal-20190209-d068a38.diff
  sudo wget https://surf.suckless.org/patches/clipboard-instead-of-primary/surf-clipboard-20200112-a6a8878.diff
  sudo wget https://surf.suckless.org/patches/startgo/surf-startgo-20200913-d068a38.diff
  sudo wget https://surf.suckless.org/patches/searchengines/surf-searchengines-20220804-609ea1c.diff
fi
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying modal patch:\n\n"
sudo git apply patches/surf-modal-20190209-d068a38.diff
printf "\nApplying clipboard patch:\n\n"
sudo git apply patches/surf-clipboard-20200112-a6a8878.diff
printf "\nApplying startgo patch:\n\n"
sudo git apply patches/surf-startgo-20200913-d068a38.diff
printf "\nApplying searchengines patch:\n\n"
sudo patch -p1 <patches/surf-searchengines-20220804-609ea1c.diff

printf "\nConfiguring patches\n\n"
sudo cp config.def.h config.h

printf "\nConfiguring searchengines patch\n\n"
sudo sed -i 's/^\(.*\)\{ " ", "https[^"]\+" \},/'$(
)'\1\{ " ", "google.com\/search?q=%s" \},/' \
  config.h
sudo sed -i \
  's/^\(.*\)\{ "osrs ", "https[^"]\+" \},/'$(
  )'\1\{ "w ", "wikipedia.org\/wiki\/%s" \},\n'$(
  )'\1\{ "d ", "dictzone.com\/angol-magyar-szotar\/%s" \},\n'$(
  )'\1\{ "de ", "dictzone.com\/magyar-angol-szotar\/%s" \},\n'$(
  )'\1\{ "y ", "youtube.com\/results?search_query=%s" \},/' \
  config.h

printf "\nConfiguring startgo patch\n\n"
sudo sed -i 's/startgo = 0/startgo = 1/' config.h

sudo git add -A
sudo git commit -m "feat: setup my base surf version"
sudo make
sudo make clean install
