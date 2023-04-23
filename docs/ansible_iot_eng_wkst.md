# Ansible - IoT Engineering workstation
## Description
This is the only Windows machine in the corp subnet that can access the Windows jumphost in the IoT subnet.


## Init Ansible playbook
1. Open `hosts.ini` and set:
```
[iot_eng_wkst]
172.16.60.20
```
1. `vim ansible/group_vars/windows.yml`

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_iot_eng_wkst.yml`


## References
* []()
