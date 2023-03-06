# Ansible - Cribl server
## Description

Deploy Cribl with role https://github.com/juju4/ansible-cribl
Refer to role for documentation

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[cribl_server]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_cribl.yml`

## References
* [juju4.cribl](https://github.com/juju4/ansible-cribl)
