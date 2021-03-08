# Automated development workstation set up

To avoid the hassle of re-installing all apps manually, I decided to maintain the development workstation set up using Ansible. Feel free to reuse :)

The general idea is to install as many packages as possible with Chocolatey which allows easy updates. The Windows should only keep UI applications and utilities required for daily routines. With the release of WSL2, most non-interactive tools I use are in a Ubuntu 20.x based WSL2 distro.

## Set up guide
> Note: this repository assumes you are running Windows 10 1903 or later running on x64 architecture.

1. Prepare Windows using the `Set-ExecutionPolicy Bypass -Scope Process; .\Init-Windows.ps1` Powershell command. Run the script with admin privileges. Some of the features require computer restart, keep rerunning the script after each restart until you see a message saying the script is finished. The script:
    - Enables Hyper-V
    - Enables WSL
    - Downloads and creates an Ubuntu 20.04 LTS distro
    - Enables Windows Remoting (so that Ansible playbook used in subsequent steps can talk to Windows host)
1. Prepare WSL distribution using the `Init-Ubuntu.sh` bash script. Run the script with sudo privileges. The script:
    - Adds Ansible repository
    - Installs latest version of Ansible
1. Apply the Windows playbook using `ansible-playbook -i inventory.yml -u <username> -k setup-win.yml`
    - Replace `<username>` for your Windows username. If it's a domain account, enter it in `user@domain` format.
    - If you get error that ntlm credentials are not allowed, you need to use different authentication technology. Check [Ansible docs](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html) for other options.
    - Restart your pc after applying this playbook to allow all start up processes to be started (e.g. gpg agent)
1. Apply the Linux playbook using `sudo ansible-playbook -i inventory.yml setup-wsl.yml`

## Development

Changes should be testing using an Azure VM which supports nested virtualization with Windows 10 Pro/Enterprise:
- Provision VM
- Copy repo/developed branch (e.g. download as zip from GitHub)
- Follow the guide above

### Testing YubiKey set up
To pass access to YubiKey to remote machine, don't forget to add passthrough to Plug'n'Play devices (the checkbox devices I plug in later) when connecting via RDP.