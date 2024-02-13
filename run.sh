#!/usr/bin/env bash
writeCommands() {
  echo "  init        - ansible and dependencies to prepare for playbook execution"
  echo "  install     - installs only dependencies from ansible galaxy"
  echo "  apply-wsl   - executes playbooks for Linux distro running in WSL"
  echo "  apply-win   - executes playbooks for Windows"
  echo "  edit-vars   - editing vault protected variables"
}

if [[ $UID == 0 ]]; then
    echo "Please do not run this script as sudo."
    exit 1
fi

case $1 in
    init)
        echo "Installing pip..."
        sudo apt install -y python3-pip

        echo "Installing Ansible via pip..."
        sudo python3 -m pip install ansible

        echo "Installing modules required for managing Windows..."
        python3 -m pip install "pywinrm>=0.3.0"
      ;;
    install)
        echo "Installing dependencies from ansible galaxy..."
        ansible-galaxy install -r requirements.yaml
      ;;
    apply-wsl)
        ansible-playbook -i inventory.yml setup-wsl.yml --vault-password-file vault.key ${@:2}
      ;;
    apply-win)
        ansible-playbook -i inventory.yml setup-win.yml --vault-password-file -K vault.key ${@:2}
      ;;
    edit-vars)
        ansible-vault edit ./group_vars/all/secrets.yaml --vault-password-file vault.key ${@:2}
      ;;
    help)
      writeCommands
      ;;
    *) 
      echo "'$1' is not a known command. Please use one of the commands below:"
      writeCommands
      ;;
esac