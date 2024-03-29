# Ansible - Metrics server
## Description
This Ansible playbook sets up Grafana and Prometheus to consume metrics from EC2 instances.

## Init Ansible playbook
1. `ansible-galaxy collection install community.crypto`
1. `vim ansible/roles/metrics_server/vars/main.yml` and set:
    1. `grafana_version` - define grafana version to use
    1. `prometheus_version` - define promtheus version to use

## Generate prometheus target list
1. `vim conf/metrics/prometheus/prometheus.yml` and add host definitions from `hosts.ini`:
```yaml
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

  - job_name: 'win-exporter'
    static_configs:
      # Corp subnet
      - targets: [
          "172.16.50.100:9100",   # win_domain_controller
          "172.16.50.101:9100",   # win_domain_controller_vuln
          "172.16.50.110:9100",   # win_file_server
          "172.16.50.130:9100",   # Windows client 1
          .
          .
          .
        ]
```

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_metrics_server.yml`

## Add Grafana to teleport
1. `tsh login --proxy=teleport.blueteamvillage.com`
1. `tctl create -f ../conf/teleport/grafana.yaml`

## Login and change password
1. Open web browser to `https://grafana.teleport.blueteamvillage.com/login`
1. Login
    1. Enter `admin` for username
    1. Enter `admin` for password
1. Enter new password

## Add Prometheus as a data source
1. Settings > Data sources
1. Select "Add data source"
1. Select "Prometheus"
1. Enter `http://localhost:9090` into  URL
1. Select "Save and test"

## Add dashboard
1. Log into Grafana
1. Create > Import
1. Find a Grafana dasboard and copy the ID
1. Enter dashboard ID into textbox
1. Select "Load"
1. Select "Prometheus (default)" for prometheus
1. Select "Import"

## Preflight checks
- [ ] - Dashboard > `Node Exporter Full`
  - [ ] - Grafana
  - [ ] - red team boxes x3
  - [ ] - SIEM boxes x4
  - [ ] - logstash ingestor
  - [ ] - DMZ webserver
- [ ] - Dashboard > `Windows Node (fixed for v0.13.0+)`
  - [ ] - Windows clients wkst01-15
  - [ ] - RDP DMZ
  - [ ] - Domain controllers x2

## Supported versions
* `Grafana v9.4.3`
* `Prometheus v2.42.0`

## References
* [ansible.builtin.get_url – Downloads files from HTTP, HTTPS, or FTP to node](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html)
* [ansible.builtin.apt – Manages apt-packages](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
* [Download Grafana](https://grafana.com/grafana/download?edition=oss)
* [Install Grafana on Debian or Ubuntu](https://grafana.com/docs/grafana/latest/installation/debian/)
* [ansible.builtin.file – Manage files and file properties](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)
* [Run Grafana behind a reverse proxy](https://grafana.com/tutorials/run-grafana-behind-a-proxy/)
* [FleetDM-Automation/roles/fleetdm/setup_ufw.yml](https://github.com/CptOfEvilMinions/FleetDM-Automation/blob/main/roles/fleetdm/setup_ufw.yml)
* [What is the default username and password for Grafana login page?](https://stackoverflow.com/questions/54039604/what-is-the-default-username-and-password-for-grafana-login-page)
* [Prometheus - HTTP API](https://prometheus.io/docs/prometheus/latest/querying/api/#status)
* [How to check if an IP address is within a range in Ansible Playbook](https://dev.to/koh_sh/how-to-check-if-an-ip-address-is-within-a-range-in-ansible-playbook-3307)
* [Install Prometheus Server on Ubuntu 22.04|20.04|18.04](https://computingforgeeks.com/install-prometheus-server-on-debian-ubuntu-linux/)
* [How to Install Prometheus on Ubuntu 20.04 LTS?](https://linuxhint.com/install-prometheus-on-ubuntu/)
* [community.general.ufw – Manage firewall with UFW](https://docs.ansible.com/ansible/latest/collections/community/general/ufw_module.html)
* [ansible.builtin.copy – Copy files to remote locations](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
* [ansible.windows.win_service – Manage and query Windows services](https://docs.ansible.com/ansible/latest/collections/ansible/windows/win_service_module.html)
* [Monitoring a Windows environment](https://cloud.ibm.com/docs/monitoring?topic=monitoring-windows)
* [ansible.windows.win_template – Template a file out to a remote server](https://docs.ansible.com/ansible/latest/collections/ansible/windows/win_template_module.html)
* [community.windows.win_firewall_rule – Windows firewall automation](https://docs.ansible.com/ansible/latest/collections/community/windows/win_firewall_rule_module.html)
* [Get-Service](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service?view=powershell-7.2)
* [ansible.windows.win_stat – Get information about Windows files](https://docs.ansible.com/ansible/latest/collections/ansible/windows/win_stat_module.html)
* [ansible.windows.win_package – Installs/uninstalls an installable package](https://docs.ansible.com/ansible/latest/collections/ansible/windows/win_package_module.html)
* [%TEMP% folder that includes the logon session ID is deleted unexpectedly](https://docs.microsoft.com/en-us/troubleshoot/windows-server/shell-experience/temp-folder-with-logon-session-id-deleted)
* [ansible.windows.win_get_url – Downloads file from HTTP, HTTPS, or FTP to node](https://docs.ansible.com/ansible/latest/collections/ansible/windows/win_get_url_module.html)
* [prometheus-community/windows_exporter](https://github.com/prometheus-community/windows_exporter)
* [Windows Server Monitoring using Prometheus and WMI Exporter](https://devconnected.com/windows-server-monitoring-using-prometheus-and-wmi-exporter/#IV_Installing_the_WMI_Exporter)
* [Run Grafana behind a reverse proxy](https://grafana.com/tutorials/run-grafana-behind-a-proxy/)
* [Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)
* [Application Access Reference Documentation](https://goteleport.com/docs/application-access/reference/)
* [Grafana 9 via Teleport Application #15375](https://github.com/gravitational/teleport/discussions/15375)
* [How to check your prometheus.yml is valid](https://www.robustperception.io/how-to-check-your-prometheus-yml-is-valid/)
* [How to filter EC2 instances in prometheus.yml?](https://stackoverflow.com/questions/57293968/how-to-filter-ec2-instances-in-prometheus-yml)
* [ec2_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config)
* [Attach IAM role to Amazon EC2 instance using Terraform](https://skundunotes.com/2021/11/16/attach-iam-role-to-aws-ec2-instance-using-terraform/)
* [Resource: aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
* [Data Source: aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)
* [Prometheus Service Discovery on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part3/)
* [community/crypto](https://galaxy.ansible.com/community/crypto)
* []()
* []()
