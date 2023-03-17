# Ansible - Velociraptor server
## Description

Velociraptor linux server

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[velociraptor_server]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_velociraptor.yml`

## References
* Alternative roles: https://github.com/PrymalInstynct/ansible_velociraptor / https://github.com/juju4/ansible_velociraptor
