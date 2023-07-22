# Ansible - Graylog
## Description
This Ansible provisions the EC2 instance to be configured by the Graylog team. This runbook just installs the node exporter agent so that we can monitor the instance via Grafana.


## Init Ansible playbook
1. Open `hosts.ini` and set:
```
[graylog]
172.16.60.170
```
1. `vim ansible/group_vars/windows.yml`


## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_graylog.yml`

## References
* []()
