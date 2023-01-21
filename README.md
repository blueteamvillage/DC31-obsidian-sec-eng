# DC31-obsidian-sec-eng

## Table of contents
<TODO>

## Network diagram
<TODO>

## pre-commit
1. To install Git hook run `pre-commit install`
1. To install pre-commit modules run `pre-commit install-hooks`
1. To update pre-commit modules run `pre-commit autoupdate`
1. Install tfsec run `go install github.com/aquasecurity/tfsec/cmd/tfsec@latest`

## AWS resource limit increase requests
### Elastic IPs
By default you get 5 Elastic IPs per region for an account but this project needs 11 Elatic IPs. Breakdown:

* 1 Elastic IP for the teleport
* 3 Elastic IP for the red team boxes
* 1 Elastic IP for the Graylog SIEM
* 1 Elastic IP for the Splunk SIEM
* 1 Elastic IP for the Elastic SIEM
* 1 Elastic IP for the SecurityOnion box
* 1 Elastic IP for the Velociraptor box
* 1 Elastic IP for the VPC NAT gateway
* 1 Elastic IP for the prod k8s

## Supported versions
* `Terraform v1.3.71`
* `Ansible v2.14.1`
* `pre_commit v2.21.0`



## References
### Terraform
* [replace Function](https://www.terraform.io/docs/language/functions/replace.html)
* [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
* [Terrafrom aws_iam_policy_document condition correct syntax](https://stackoverflow.com/questions/62831874/terrafrom-aws-iam-policy-document-condition-correct-syntax)
* [aws_iam_group_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment)
* []()
* []()
* []()
* []()
* []()
* []()

### Windows
* [Jinja convert string to integer](https://stackoverflow.com/questions/39938323/jinja-convert-string-to-integer)
* [How to count objects in PowerShell?](https://stackoverflow.com/questions/11526285/how-to-count-objects-in-powershell)
* [Get-DnsServerResourceRecord](https://docs.microsoft.com/en-us/powershell/module/dnsserver/get-dnsserverresourcerecord?view=windowsserver2022-ps)
* [Add-DnsServerResourceRecordMX](https://docs.microsoft.com/en-us/powershell/module/dnsserver/add-dnsserverresourcerecordmx?view=windowsserver2022-ps)
* [community.windows.win_dns_record – Manage Windows Server DNS records](https://docs.ansible.com/ansible/latest/collections/community/windows/win_dns_record_module.html)
* []()
* []()
* []()
* []()
* []()
* []()
* []()
