#!/bin/sh
# This script just symbolically links the content of nnn/plugins directory
# the user's plugin directory. It assumes that the install_nnn.sh is already
# and the script is ran in the void-rice directory.

USER_PLUGINS_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/nnn/plugins
cd nnn || return 1

mkdir -p $USER_PLUGINS_DIR || return 1

ln -sf $(pwd)/plugins/* "$USER_PLUGINS_DIR"
