# Ansible - Metrics server
## Description
This Ansible playbook sets up Grafana and Prometheus to consume metrics from EC2 instances.

## Init Ansible playbook
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


## Login and change password
1. Open web browser to `https://172.16.10.100/login`
1. Login
    1. Enter `admin` for username
    1. Enter `admin` for password
1. Enter new password

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
* []()
