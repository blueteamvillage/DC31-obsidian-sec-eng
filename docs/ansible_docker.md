# Ansible - Docker server
## Description

Standard Linux server with docker using https://github.com/geerlingguy/ansible-role-docker

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[docker_server]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_docker.yml`

## Troubleshooting, known issues

* Setup was first to directly call ansible docker module for mariadb and mediawiki but it didn't work. Switched to docker compose setup which is functional.

## References
* [geerlingguy.docker](https://github.com/geerlingguy/ansible-role-docker)
