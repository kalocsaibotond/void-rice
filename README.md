# My personal quasi-suckless void linux setup

It constutites from two main part.
The first part is minimalistic quasi-suckless desktop environment base.
The other part are are just dependencies of utilities I use.

The minimalistic quasi-suckless base can be installed with the
`./install_de_base.sh` script. It contains two parallel suckless desktop
environment. One is the regular suckless window manager (GUI) based environment.
The other is a full terminal based emulation of the former as much as possible.
The latter is in plan but I have not implemented it yet.

The other part are are just dependencies of stuff I use. This can be installed
with the `./install_de_utils.sh` which just install the dependencies listed
in `./de_util_deps.txt`. Here I primarily try to include cross platform
utilities.

To install the full desktop environment, run:

```bash
git clone https://github.com/kalocsaibotond/void-rice
cd void-rice
chmod +x *
./install_de_base.sh; ./install_de_utils.sh
```

To install without SSL verification, run:

```bash
GIT_SSL_NO_VERIFY=true git clone https://github.com/kalocsaibotond/void-rice
cd void-rice
chmod +x *
./install_de_base.sh true; ./install_de_utils.sh true
```

The overarching aim of my overall desktop environment is to optimise for
terminal usage, and minimise GUI and mouse usage, but have proper mouse
support as backup solution. Nevertheless I try to make it as much suckless as
reasonably achievable.

Here everything is subject to breaking change, so only use the content as
inspiration. Moreover, currently it is in a work-in-progress state.
