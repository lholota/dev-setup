#!/usr/bin/env bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo "Updating apt..."
apt update

echo "Installing deps to add Ansible ppa..."
apt install -y software-properties-common

echo "Adding Ansible ppa"
apt-add-repository --yes --update ppa:ansible/ansible

echo "Installing ansible"
apt install -y ansible