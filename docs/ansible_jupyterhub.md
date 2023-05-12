# Ansible - Jupyterhub over k3s server
## Description

Linux server with k3s and jupyterhub.

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[jupyterhub_server]`, `[ks3_group]`, `[ks3_cluster]`, `[ks3_masters]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_jupyterhub.yml`

## Troubleshooting, known issues

TBD

## References
* https://github.com/blueteamvillage/DC31-obsidian-sec-eng/issues/46
* https://github.com/juju4/ansible-jupyterhub/ fork of https://github.com/CyVerse-Ansible/ansible-jupyterhub
* https://github.com/juju4/ansible-k3s/ fork of https://github.com/CyVerse-Ansible/ansible-k3s
