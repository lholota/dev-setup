#!/usr/bin/env bash
case $1 in
    init)
        if [[ $UID != 0 ]]; then
            echo "This command must be run with sudo permissions."
            exit 1
        fi

        echo "Installing pip..."
        apt install -y python3-pip

        echo "Installing Ansible via pip..."
        python3 -m pip install ansible

        echo "Installing dependencies from ansible galaxy..."
        ansible-galaxy install -r requirements.yaml
      ;;
    install)
        echo "Installing dependencies from ansible galaxy..."
        ansible-galaxy install -r requirements.yaml
      ;;
    apply)
        ansible-playbook -i inventory.yaml setup.yaml --vault-password-file vault.key ${@:2}
      ;;
    edit-vars)
        ansible-vault edit ./host_vars/localhost.yaml
      ;;
    *) 
      echo "'$1' is not a known command. Please use one of the commands below:"
      echo "\t init \t- ansible and dependencies to prepare for playbook execution"
      echo "\t install \t- installs only dependencies from ansible galaxy"
      echo "\t apply \t- executes the core playbook, you can add --tags <tag1,tag2> to execute only specific parts"
      echo "\t edit-vats \t- editing vault protected variables"
      ;;
esac
