#/bin/bash

sign_krn_mod_vbox=$0

function usage {
    echo "usage: $sign_krn_mod_vbox [keyname]"
}

function ask_key {
  if [ -z "$1" ]; then
    echo 'You need to specify a key name to sign the virtualbox module.'
    exit 1
  fi
}

function checkmok {
  checkmok="$(sudo find /boot -name MokManager.efi)"
  if [[ -z "$checkmok" ]]; then
    echo "MokManager.efi not found, can't proceed."
    exit 1
  fi
}

function genkey_sign {
  openssl req -new -x509 -newkey rsa:2048 -keyout $1.priv -outform DER -out $1.der -nodes -days 36500 -subj "/CN=vbox_custom/"
  for i in $(dirname $(modinfo -n vboxdrv))/*.ko; do echo "Signing $i"; sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 ./$1.priv ./$1.der $i; done
}

usage
ask_key $1
checkmok 
genkey_sign $1

echo "This password will be asked at boot time once, remember it :)"
sudo mokutil --import $1.der
echo "You can reboot your machine, press enter when the MOK menu appears at boot time, enroll your key and type the password you chose previously."
