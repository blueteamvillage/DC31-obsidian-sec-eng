# Ansible - Security Onion server
## Description

Setup based on DC30 code

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[security_onion]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_security_onion.yml`

If it is the first execution or the one to setup or renew letsencrypt certificate, you must open aws security group from all sources aka 0.0.0.0 temporarily, either from Terraform, either from web portal.

Credentials to have cribl data ingestion (so_elastic user):
```
$ sudo cat /opt/so/conf/elasticsearch/curl.config
```

Add user manually (webuser not included in initial setup)
```
$ sudo so-user-add webuser@magnumtempusfinancial.com
Enter new password:
Syncing users and roles between SOC and Elastic...
Elastic state will be re-applied to affected minions. This may take several minutes...
Successfully added new user to SOC
Successfully added user to Fleet
Successfully updated Fleet user password

```

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

* User password reset with `so-user` - https://docs.securityonion.net/en/2.3/passwords.html

* Change base url - https://docs.securityonion.net/en/2.3/url-base.html
This has been integrated in ansible code "Set SecurityOnion url_base"

* Stenographer/Sensoroni: It generates "pcap view" on-demand by calling REST api with same fqdn than all security-onion which wrongly ends to teleport. Workaround is included in ansible role. See below for troubleshooting and manual fix.

```shell
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# tail /opt/so/log/sensoroni/sensoroni.log
timestamp=2023-04-27T00:08:30.439088318Z level=warn message="Failed to poll for pending jobs" error="invalid character '<' looking for beginning of value"
timestamp=2023-04-27T00:08:31.443774769Z level=info message="HTTP request finished" contentLength=777 method=POST status="200 OK" statusCode=200 url=https://securityonion.teleport.blueteamvillage.com/sensoroniagents/api/node
timestamp=2023-04-27T00:08:31.443852581Z level=warn message="Failed to poll for pending jobs" error="invalid character '<' looking for beginning of value"
timestamp=2023-04-27T00:08:32.448882057Z level=info message="HTTP request finished" contentLength=777 method=POST status="200 OK" statusCode=200 url=https://securityonion.teleport.blueteamvillage.com/sensoroniagents/api/node
timestamp=2023-04-27T00:08:32.449051989Z level=warn message="Failed to poll for pending jobs" error="invalid character '<' looking for beginning of value"


root@securityonion:/opt/so/saltstack/local/salt/soc/files/soc# cd /opt/so/saltstack/local/salt/sensoroni/files/
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# ls
analyzers  sensoroni.json
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# vim sensoroni.json
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# docker stop so-sensoroni
so-sensoroni
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# docker rm so-sensoroni
so-sensoroni
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# salt-call state.apply sensoroni
local:
    Data failed to compile:
----------
    The function "state.highstate" is running as PID 108978 and was started at 2023, Apr 27 00:43:33.298741 with jid 20230427004333298741
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# salt-call salt-util.kill_all_jobs
'salt-util.kill_all_jobs' is not available.
root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# salt-call state.apply sensoroni queue=True

[...]

root@securityonion:/opt/so/saltstack/local/salt/sensoroni/files# tail /opt/so/log/sensoroni/sensoroni.log
timestamp=2023-04-27T00:48:56.202908504Z level=info message="HTTP request finished" contentLength=10 method=POST status="405 Method Not Allowed" statusCode=405 url=http://172.16.22.23:9822/sensoroniagents/api/node
timestamp=2023-04-27T00:48:56.203035283Z level=warn message="Failed to poll for pending jobs" error="Request did not complete successfully (405): 405 Method Not Allowed"
timestamp=2023-04-27T00:48:57.203586868Z level=info message="HTTP request finished" contentLength=10 method=POST status="405 Method Not Allowed" statusCode=405 url=http://172.16.22.23:9822/sensoroniagents/api/node
timestamp=2023-04-27T00:48:57.203648628Z level=warn message="Failed to poll for pending jobs" error="Request did not complete successfully (405): 405 Method Not Allowed"
timestamp=2023-04-27T00:48:58.204556357Z level=info message="HTTP request finished" contentLength=10 method=POST status="405 Method Not Allowed" statusCode=405 url=http://172.16.22.23:9822/sensoroniagents/api/node
timestamp=2023-04-27T00:48:58.204653405Z level=warn message="Failed to poll for pending jobs" error="Request did not complete successfully (405): 405 Method Not Allowed"
timestamp=2023-04-27T00:48:59.205711482Z level=info message="HTTP request finished" contentLength=10 method=POST status="405 Method Not Allowed" statusCode=405 url=http://172.16.22.23:9822/sensoroniagents/api/node
timestamp=2023-04-27T00:48:59.205776237Z level=warn message="Failed to poll for pending jobs" error="Request did not complete successfully (405): 405 Method Not Allowed"
timestamp=2023-04-27T00:49:00.206390816Z level=info message="HTTP request finished" contentLength=10 method=POST status="405 Method Not Allowed" statusCode=405 url=http://172.16.22.23:9822/sensoroniagents/api/node
timestamp=2023-04-27T00:49:00.20647293Z level=warn message="Failed to poll for pending jobs" error="Request did not complete successfully (405): 405 Method Not Allow"

ubuntu@securityonion:~$ sudo grep -C2 serverUrl /opt/so/saltstack/default/salt/sensoroni/files/sensoroni.json
    "model": "{{ MODEL }}",
    "pollIntervalMs": {{ CHECKININTERVALMS if CHECKININTERVALMS else 10000 }},
    "serverUrl": "https://{{ URLBASE }}/sensoroniagents",
    "verifyCert": false,
    "modules": {
ubuntu@securityonion:~$ sudo grep -C2 serverUrl /opt/so/saltstack/local/salt/sensoroni/files/sensoroni.json
    "model": "{{ MODEL }}",
    "pollIntervalMs": {{ CHECKININTERVALMS if CHECKININTERVALMS else 10000 }},
    "serverUrl": "http://172.16.22.23:9822",
    "verifyCert": false,
    "modules": {

ubuntu@securityonion:~$ tail /opt/so/log/sensoroni/sensoroni.log
timestamp=2023-04-27T01:13:32.160270618Z level=info message="HTTP request finished" contentLength=-1 method=POST status="200 OK" statusCode=200 url=http://172.16.22.23:9822/api/node
timestamp=2023-04-27T01:13:33.161706002Z level=info message="HTTP request finished" contentLength=-1 method=POST status="200 OK" statusCode=200 url=http://172.16.22.23:9822/api/node
timestamp=2023-04-27T01:13:34.163181558Z level=info message="HTTP request finished" contentLength=-1 method=POST status="200 OK" statusCode=200 url=http://172.16.22.23:9822/api/node
```

## References
* [install_security_onion.yml](https://github.com/blueteamvillage/obsidian-sec-eng/blob/main/ansible/roles/linux/install_security_onion.yml)
* [conf/security_onion](https://github.com/blueteamvillage/obsidian-sec-eng/tree/main/ansible/conf/security_onion)
* [Traffic Mirroring considerations](https://docs.aws.amazon.com/vpc/latest/mirroring/traffic-mirroring-considerations.html)
* [describe-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html)
* [Data Source: aws_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances)
* [Data Source: aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance#private_ip)
* [Filter Terraform Data Source by AWS Tag](https://wahlnetwork.com/2020/04/30/filter-terraform-data-source-by-aws-tag-value/)
* [Allow user to change web interface cert #1766 ](https://github.com/Security-Onion-Solutions/securityonion/issues/1766)
* []()
* []()
