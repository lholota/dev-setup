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
python -m pip install ansible

echo "Done :)"