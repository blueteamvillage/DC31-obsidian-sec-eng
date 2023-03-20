# Ansible - Vulnerable Log4j web server
## Description
This will provision a Windows Server to be a domain controller

## Init Ansible playbook
1. Install Python package `ipaddr`: `pip3 install -U netaddr`
1. Install WinRM for Python: `ansible-galaxy collection install ansible.windows`
1. Install AWS packages for Ansible: `ansible-galaxy collection install amazon.aws`
1. Install the Python package Boto to interact with AWS: `pip3 install -U boto3==1.26.69`
1. `vim ansible/group_vars/windows.yml` and set:
    `ansible_password` - Set secret name to `${var.PROJECT_PREFIX}_win_domain_admin_passwd`
1. `vim hosts.ini` and set `[win_domain_controller]` to `127.0.0.1`

## Run Ansible playbook
1. `tsh ssh -L 5986:<Win DC IP addr>:5986 ubuntu@<telport node IP addr>`
    1. Create SSH tunnel for WinRM connections
1. `ansible-playbook -i hosts.ini deploy_domain_controller.yml`

## Install Teleport
1. Open Powershell as Administrator
```powershell
$ErrorActionPreference = "Stop"

Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -HashAlgorithmName SHA384 -Force
Restart-Computer -Force
```
1. `(Invoke-WebRequest -Uri https://teleport.blueteamvillage.com/v1/webapi/scripts/desktop-access/configure/8085d934a8635b609dddacb46b03c284/configure-ad.ps1).Content | Invoke-Expression`
1. Copy config output

## Teleport cluster setup
1. SSH into Teleport
1. Add the teleport config output from above
    1. [Example config](../conf/teleport/teleport.yaml)
1. Restart Teleport

## Set up Teleport Access
1. `tctl create -f conf/teleport/windows_desktop_admins.yaml`

## References
* [ansible.windows.win_service module ](https://docs.ansible.com/ansible/latest/collections/ansible/windows/win_service_module.html)
* [Getting Started with Desktop Access](https://goteleport.com/docs/desktop-access/getting-started/)
* [Getting started with Teleport Desktop Access for Windows Servers](https://www.youtube.com/watch?v=YvMqgcq0MTQ)
