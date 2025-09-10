#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  export WGETRC="$(pwd)/.wgetrc"
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY,WGETRC'
else
  env_vars=''
fi

printf "\nInstalling surf\n\n"
sudo $env_vars git clone https://git.suckless.org/surf
cd surf || return 1
sudo git checkout -b my_surf || return 1

printf "\nDownloading patches or fetching local patches:\n\n"
sudo mkdir patches
cd patches
sudo cp ../../local_patches/surf/searchengines/surf-searchengines-20250802-48517e5.diff .
sudo $env_vars wget \
  https://surf.suckless.org/patches/modal/surf-modal-20190209-d068a38.diff
sudo $env_vars wget \
  https://surf.suckless.org/patches/clipboard-instead-of-primary/surf-clipboard-20200112-a6a8878.diff
sudo $env_vars wget \
  https://surf.suckless.org/patches/startgo/surf-startgo-20200913-d068a38.diff
# sudo $env_vars wget \
#   https://surf.suckless.org/patches/searchengines/surf-searchengines-20220804-609ea1c.diff
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying modal patch:\n\n"
sudo git apply patches/surf-modal-20190209-d068a38.diff
printf "\nApplying clipboard patch:\n\n"
sudo git apply patches/surf-clipboard-20200112-a6a8878.diff
printf "\nApplying startgo patch:\n\n"
sudo git apply patches/surf-startgo-20200913-d068a38.diff
printf "\nApplying searchengines patch:\n\n"
sudo patch -p1 <patches/surf-searchengines-20250802-48517e5.diff

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

echo 'set number
/uri/ append

if ! [ -d $(dirname $xidfile) ]; then
	mkdir -p $(dirname $xidfile)
fi
.
xit' | sudo ex surf-open.sh
sudo ln -sf $(pwd)/surf-open.sh /usr/local/bin/tsurf

sudo git add -A
sudo git commit -m "feat: setup my base surf version"
sudo make
sudo make clean install
