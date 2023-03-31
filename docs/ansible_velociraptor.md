# Ansible - Velociraptor server
## Description

Velociraptor linux server

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[velociraptor_server]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_velociraptor.yml`

## Troubleshooting, Known issues

* during initial setup and cert renewal, need to temporarily open to get public certificate with certbot
`terraform apply -target=aws_security_group_rule.velociraptor_allow_https -target=aws_security_group_rule.velociraptor_allow_http`
https://certbot.eff.org/faq#what-ip-addresses-will-the-let-s-encrypt-servers-use-to-validate-my-web-server

## References
* Alternative roles: https://github.com/PrymalInstynct/ansible_velociraptor / https://github.com/juju4/ansible_velociraptor
