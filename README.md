## Full disk encryption unlock with YubiKey
The playbook will only install the required packages, given that the configuration depends on the disk layout it is not configured automatically by design. The general steps are (inspired by https://github.com/cornelinux/yubikey-luks) 
- Enable challenge/response mode if not enabled already: ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible
    Note: slot 2 selected by design, requires hlding the yubikey which is ok during the start
- Enroll yubikey-luks into the keystore: yubikey-luks-enroll -s 1 -d /dev/nvme0n1p2


# Before running - copy password to key file


## Manual steps post running the runbook
- set up google TOTP
- set up U2f key registration
- configure kopia













# Automated development workstation set up

To avoid the hassle of re-installing all apps manually, I decided to maintain the development workstation set up using Ansible.

The general idea is to install as many packages as possible with Chocolatey which allows easy updates. The Windows should only keep UI applications and utilities required for daily routines. With the release of WSL2, most non-interactive tools I use are in a Ubuntu 20.x based WSL2 distro.

> Note: this repo contains set up for what I need, it's not aimed to create a generic set up for any developer. Fork the repo for customizations.

## What's in the box

The scripts and playbooks:

- Enable WSL2 along with all required dependencies
- Install basic apps - check the [yml file](./windows/util-packages.yml) for full list (chrome, 7-zip etc.)
- Install development tools like VS Code, Docker desktop or Visual Studio - check the [yml file](./windows/dev-packages.yml) for full list
- Set up [Powerline shell](https://github.com/b-ryan/powerline-shell) compatible fonts so you can use it in Windows Terminal or via `wsl.exe`
- Set up YubiKey relay so that you can use your YubiKey as:
    - an SSH key from WSL to connect to remote machines
    - an SSH key from WSL to connect to remote git origins
    - a GPG key for encryption from both WSL and Windows (via GPG4Win)
    - sign git commits when commiting from Windows via GitKraken
- Install SDKs for Golang, Python (implied by Ansible), .NET Core and NodeJS (all in WSL)

## Set up guide
> Note: this repository assumes you are running Windows 10 1903 or later running on x64 architecture.

1. Prepare Windows using the `Set-ExecutionPolicy Bypass -Scope Process; .\Init-Windows.ps1` Powershell command. Run the script with admin privileges. Some of the features require computer restart, keep rerunning the script after each restart until you see a message saying the script is finished. The script:
    - Enables Hyper-V
    - Enables WSL
    - Downloads and creates an Ubuntu 20.04 LTS distro
    - Enables Windows Remoting (so that Ansible playbook used in subsequent steps can talk to Windows host). Feel free to disable the remoting after the configuration has been completed.
1. Prepare WSL distribution using the `sudo ./Init-Ubuntu.sh` bash command. The script must be run with sudo privileges. (the script adds Ansible repository and installs latest version of Ansible). If you have an older version of Ansible already installed, make sure you uninstall it first.
1. Install dependencies with `ansible-galaxy install -r requirements.yml`
1. Apply the Windows playbook using `ansible-playbook -i inventory.yml -u <username> -k setup-win.yml`
    - Replace `<username>` for your Windows username. If it's a domain account, enter it in `user@domain` format.
    - Ansible will ask you for `SSH Password` which is a bit unfortunate phrasing, it's actually asking for your Windows password.
    - If you get error that ntlm credentials are not allowed, you need to use different authentication technology. Check [Ansible docs](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html) for other options.
    - The playbook may restart the pc without prior notice. If it does, repeat applying this playbook after the restart until the whole playbook is finished.
1. Apply the Linux playbook using `ansible-playbook -i inventory.yml -K setup-wsl.yml`
    - Ansible will ask you for password, this is to allow assuming sudo (required to install packages)

## Development

Changes should be testing using an Azure VM which supports nested virtualization with Windows 11 Pro/Enterprise:
- Provision VM
- Copy repo/developed branch (e.g. download as zip from GitHub)
- Follow the guide above

### Testing YubiKey set up
To pass access to YubiKey to remote machine, don't forget to add passthrough to Plug'n'Play devices (the checkbox devices I plug in later) when connecting via RDP.