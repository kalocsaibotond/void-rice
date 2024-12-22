#!/bin/sh

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

echo 'set number
/startgo =
.,. s/=[^=]\{1,\};/= 1;/
/searchengines\[\] =
+
.,/};/- change
	{ " ", "https://google.com/search?q=%s" },
	{ "w ", "https://wikipedia.org/wiki/%s" },
	{ "d ", "https://dictzone.com/angol-magyar-szotar/%s" },
	{ "de ", "https://dictzone.com/magyar-angol-szotar/%s" },
	{ "y ", "https://youtube.com/results?search_query=%s" },
.
xit' | sudo ex config.h

ln -sf $(pwd)/surf-open.sh /usr/local/bin/tsurf

sudo git add -A
sudo git commit -m "feat: setup my base surf version"
sudo make
sudo make clean install
