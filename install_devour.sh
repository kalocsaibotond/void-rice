#!/bin/sh

printf "\nInstalling devour\n\n"
sudo GIT_SSL_NO_VERIFY=$1 git clone https://github.com/salman-abedin/devour
cd devour
sudo git checkout -b my_devour

printf "\nApplying shellalias patch:\n\n"
sudo patch -s <devour-shellalias-10.0.diff

sudo make install
