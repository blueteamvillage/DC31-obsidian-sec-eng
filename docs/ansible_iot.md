# Ansible - IoT environment
## Description

Set up linux server with openplc and other IoT tools.
Starter with a single server and openplc

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[iot]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_docker.yml`

## References
* https://github.com/ait-cs-IaaS/ansible-openplc
