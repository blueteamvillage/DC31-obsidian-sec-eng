# Ansible - Vulnerable Log4j web server
## Description
This playbook will join the Windows clients to the Windows domain.


## Init Ansible playbook
1. Install Python package `ipaddr`: `pip3 install -U netaddr`
1. Install WinRM for Python: `ansible-galaxy collection install ansible.windows`
1. Install AWS packages for Ansible: `ansible-galaxy collection install amazon.aws`
1. Install the Python package Boto to interact with AWS: `pip3 install -U boto3==1.26.69`
1. `vim ansible/group_vars/windows.yml` and set:
    `ansible_password` - Set secret name to `${var.PROJECT_PREFIX}_win_domain_admin_passwd`
1. `vim hosts.ini` and set `[win_clients]` to `127.0.0.1`

## Run Ansible playbook
1. `tsh ssh -L 5986:<Win client IP addr>:5986 ubuntu@<telport node IP addr>`
    1. Create SSH tunnel for WinRM connections
1. `ansible-playbook -i hosts.ini deploy_windows_clients.yml`


## References
* []()
