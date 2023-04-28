# Ansible - Security Onion server Arkime part
## Description

Deploy Arkime on SecurityOnion server for full pcap capture

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[security_onion]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_security_onion_arkime.yml`

## Troubleshooting/Known issues

* This mostly ensure a classical network view compare to stenographer included in securityonion

* Ensure to also open firewall ports on securityonion following https://docs.securityonion.net/en/2.3/firewall.html. Target chain is INPUT and port 8005.

## References
* https://github.com/juju4/ansible-arkime
* https://arkime.com/
* https://github.com/geerlingguy/ansible-role-elasticsearch
* [Traffic Mirroring considerations](https://docs.aws.amazon.com/vpc/latest/mirroring/traffic-mirroring-considerations.html)
* []()
* []()
