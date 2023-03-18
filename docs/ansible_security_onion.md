# Ansible - Security Onion server
## Description

Setup based on DC30 code

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[security_onion]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_security_onion.yml`

## Troubleshooting/Known issues

* Don't try ec2 size below recommended xlarge. Install is heavy and using smaller size will results in oom-killer, slowness (40min deployment vs 3h+/incomplete)  and other issues.

* Ensure to update aws mirroring settings to target servers. When terraform apply is executed, security onion server must be running or else it will result in an error.

* Intermittent privilege escalation prompt issue. maybe related to undersize ec2.
```
TASK [Run the Security Onion automated setup script - async] *********************************************************************************************************************************************************
Friday 17 March 2023  20:01:57 +0000 (0:00:30.037)       0:01:11.670 **********
changed: [btv_so] => {"ansible_job_id": "863678055072.5627", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/863678055072.5627", "started": 1}

TASK [Check on sosetup async task] ***********************************************************************************************************************************************************************************
Friday 17 March 2023  20:02:00 +0000 (0:00:02.365)       0:01:14.035 **********
FAILED - RETRYING: [btv_so]: Check on sosetup async task (150 retries left).
FAILED - RETRYING: [btv_so]: Check on sosetup async task (149 retries left).
[...]
FAILED - RETRYING: [btv_so]: Check on sosetup async task (111 retries left).
FAILED - RETRYING: [btv_so]: Check on sosetup async task (110 retries left).
fatal: [btv_so]: FAILED! => {"msg": "Timeout (12s) waiting for privilege escalation prompt: "}
```

* To fully rebuild aws side of securityonion and dependencies:
```
terraform destroy -target=aws_instance.securityonion_server
terraform apply -target=aws_instance.securityonion_server -target=aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter -target=aws_ec2_traffic_mirror_filter_rule.seconion_traffic_mirror_ipv4_filter_rule_egress -target=aws_ec2_traffic_mirror_filter_rule.seconion_traffic_mirror_ipv4_filter_rule_ingress -target=aws_ec2_traffic_mirror_filter_rule.seconion_traffic_mirror_ipv6_filter_rule_egress -target=aws_ec2_traffic_mirror_filter_rule.seconion_traffic_mirror_ipv6_filter_rule_ingress -target=aws_ec2_traffic_mirror_session.corp_docker_server_traffic_mirror_session -target=aws_ec2_traffic_mirror_session.dmz_web_server_subnet_traffic_mirror_session  -target=aws_ec2_traffic_mirror_session.domain_controller_traffic_mirror_session -target=aws_ec2_traffic_mirror_target.seconion_traffic_mirror_target -target=aws_security_group.securityonion_server_sg2
```

## References
* https://github.com/blueteamvillage/obsidian-sec-eng/tree/main/ansible/conf/security_onion
* https://github.com/blueteamvillage/obsidian-sec-eng/blob/main/ansible/roles/linux/install_security_onion.yml
