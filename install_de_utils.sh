# Installing other utilites of my desktop environment
if [ "$EUID" -ne 0 ]; then
  echo "The script has to be run as root."
  exit
fi

echo "Lastly installing the utilites of my desktop environment"
sudo SSL_NO_VERIFY_PEER=$1 xbps-install \
  -Sy "$(./parsedeps.sh de_util_deps.txt)"

chezmoi init kalocsaibotond
