# dwm is installed into opt
cd /opt

echo "Installing dwm"
GIT_SSL_NO_VERIFY=$1 git clone https://git.suckless.org/dwm
cd dwm
git checkout -b my_dwm

# Set win key as mod
sed -i 's/^#define MODKEY Mod1Mask$/#define MODKEY Mod4Mask/' ./config.def.h

# Eliminating all window rules.
sed -i '/Gimp/d' ./config.def.h
sed -i 's/{ "Firefox.*/{ NULL,       NULL,       NULL,       0,            '$(
)'False,       -1 },/' ./config.def.h

git add ./config.def.h
git commit -m "feat: setup my base dwm version"
make
sudo make clean install
