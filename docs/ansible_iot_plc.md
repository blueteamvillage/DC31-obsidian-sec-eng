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

## Troubleshooting

* amazon-ssm-agent eating CPU: Should we just remove the package?
```
sudo snap stop amazon-ssm-agent
```
See also https://docs.aws.amazon.com/systems-manager/latest/userguide/troubleshooting-ssm-agent.html

* sysmon seems too memory consuming to be used on t3.nano with just 512MB RAM, especially more if amazon-ssm-agent has issue too. put velociraptor on hold too. ok with t3.micro aka 1GB RAM.

* Not sure if related to ec2 size again but seems to get more often UNREACHABLE errors from ansible
```
UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Connection timed out during banner exchange\r\nConnection to UNKNOWN port 65535 timed out", "unreachable": true}
```

## References
* https://github.com/ait-cs-IaaS/ansible-openplc
