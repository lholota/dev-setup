#!/usr/bin/env bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo "Updating apt..."
apt update

echo "Installing pip..."
apt install -y python3-pip

echo "Installing Ansible via pip..."
python3 -m pip install ansible

echo "Done :)"
echo "Please don't forget to re-open shell to allow the change of PATH variable to take effect (otherwise ansible will not be in PATH)"