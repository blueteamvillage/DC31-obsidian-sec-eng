# Ansible - Elastic server
## Description

Elasticsearch server

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[elastic]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_elastic.yml`

## References
* []()
