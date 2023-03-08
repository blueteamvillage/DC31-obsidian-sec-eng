# Ansible - Security Onion server
## Description

Setup based on DC30 code

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[security_onion]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_security_onion.yml`

## References
* https://github.com/blueteamvillage/obsidian-sec-eng/tree/main/ansible/conf/security_onion
* https://github.com/blueteamvillage/obsidian-sec-eng/blob/main/ansible/roles/linux/install_security_onion.yml
