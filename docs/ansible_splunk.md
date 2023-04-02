# Ansible - Splunk server
## Description

Deploy Splunk with splunk-ansible collection.

Outside of few apps, most configuration is not included at this point.

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[splunk]` to the IP address of the server

## Run Ansible playbook
1. Review group_vars/splunk
1. Ensure to have splunk deb archive downloaded and available on orchestrator
1. Splunk apps should be uploaded on splunk server beforehand and matching app_paths_install
1. `ansible-playbook -i hosts.ini deploy_splunk.yml`

## References
* https://splunk.github.io/splunk-ansible/
* https://splunk.github.io/splunk-ansible/advanced/default.yml.spec.html#sample
