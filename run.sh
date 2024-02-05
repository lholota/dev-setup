#!/usr/bin/env bash
writeCommands() {
  echo "  init        - ansible and dependencies to prepare for playbook execution"
  echo "  install     - installs only dependencies from ansible galaxy"
  echo "  apply       - executes the core playbook, you can add --tags <tag1,tag2> to execute only specific parts"
  echo "  apply:work  - executes the core playbook for work machines"
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
      ;;
    install)
        echo "Installing dependencies from ansible galaxy..."
        ansible-galaxy install -r requirements.yaml
      ;;
    apply)
        ansible-playbook -i inventory.yaml setup.yaml --vault-password-file vault.key ${@:2}
      ;;
    apply:work)
        ansible-playbook -i inventory.yaml setup.yaml --extra-vars "workstation_type=work" --vault-password-file vault.key ${@:2}
      ;;
    edit-vars)
        ansible-vault edit ./host_vars/localhost.yaml --vault-password-file vault.key ${@:2}
      ;;
    help)
      writeCommands
      ;;
    *) 
      echo "'$1' is not a known command. Please use one of the commands below:"
      writeCommands
      ;;
esac
