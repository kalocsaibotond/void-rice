#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling hkd\n\n"
sudo $env_vars git clone 'https://github.com/aaronamk/hkd.git'
cd hkd || return '1'
sudo git checkout -b 'my_hkd' || return '1'

printf "\nConfiguring hkd\n\n"
sudo cp 'config.h' 'config.def.h'

echo 'set number
/pulseaudio/ s/pulseaudio/alsa/

/vol_up/,/mute/ change
static const char *vol_up[] = { "amixer", "set", "Master", "2%+", NULL };
static const char *vol_down[] = { "amixer", "set", "Master", "2%-", NULL };
static const char *vol_toggle_mute[] = { "amixer", "set", "Master", "toggle", NULL };
.

/term/-,/shutdown/ change
static const char *restart_hkd[] = { "nohup", "sv" "restart", "hkd", "&", NULL };
.

/term/,/shutdown/ change
    { M_CTRL|M_ALT|M_SHIFT|M_META, KEY_H,         restart_hkd }
.

xit' | sudo ex config.h

sudo git add -A
sudo git commit -m "feat: setup my base hkd version"
sudo make install

printf "\nMaking runit service from hkd and configure it.\n\n"

if ! [ -f '/etc/sv/hkd/run' ]; then
  cat <<'EOF' >run
#!/bin/sh

# WARN: The following commands are needed to prevent a disabled input
# device state with hkd affected input devices (like keyboards).
# NOTE: For each affected devices, hkd clones the device file. it mutes
# original device files and emits the hardware input through the clone
# device files (in a filtered manner).
# During boot, for some reason eudev fails to tag the clone files with the
# appropriate attributes and/or properties (for keyboard ID_INPUT_KEY=1 and
# ID_INPUT_KEYBOARD=1 properties) that Xorg uses for input device
# identification.
# The following commands are to force eudev into a consistent, steady state
# during boot, in which eudev does its job properly.

for dev_path in $(readlink -f /dev/input/by-path/*kbd); do
  sys_path="/sys/class/input/$(basename "$dev_path")"
  udevadm test-builtin 'input_id' "$sys_path" >'/dev/null' 2>&1
done

exec '/usr/local/bin/hkd' /dev/input/by-path/*kbd >'/dev/null'
EOF
  chmod o+rx 'run'
  sudo mkdir -p '/etc/sv/hkd'
  sudo mv run '/etc/sv/hkd/'
fi

sudo ln -sf '/etc/sv/hkd' '/var/service'

printf "\nCreating udev rule for restarting when new keyboard is connected.\n\n"

if ! [ -f '/etc/udev/rules.d/99-restart-hkd.rules' ]; then
  echo '#!/bin/sh
if sv status hkd | grep -q "^run"; then
  sv restart hkd > /dev/null
fi' >'restart_hkd.sh'
  chmod o+rx 'restart_hkd.sh'

  # NOTE: This rule is inspired from the by-path link rules of Void linux's
  # /lib/udev/rules.d/60-persistent-input.rules . It applies upon any keyboard
  # (including the ones on mice, etc...) addition.
  rules=''
  rules="$rules"'SUBSYSTEMS=="pci|usb|platform|acpi", '
  rules="$rules"'IMPORT{builtin}="path_id"'
  rules="$rules\n"
  rules="$rules"'ACTION=="add", '
  rules="$rules"'SUBSYSTEM=="input", '
  rules="$rules"'KERNEL=="event*", '
  rules="$rules"'ENV{ID_PATH}=="?*", '
  rules="$rules"'ENV{ID_INPUT_KEYBOARD}=="1", '
  rules="$rules"'RUN+="/etc/udev/restart_hkd.sh"'
  echo "$rules" >'99-restart-hkd.rules'
  chmod o+rx '99-restart-hkd.rules'

  sudo mkdir -p '/etc/udev/rules.d'

  sudo mv 'restart_hkd.sh' '/etc/udev/'
  sudo mv '99-restart-hkd.rules' '/etc/udev/rules.d'
fi
