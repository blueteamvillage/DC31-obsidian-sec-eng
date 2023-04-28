# Ansible - Cribl server
## Description

Deploy Cribl with role https://github.com/juju4/ansible-cribl
Refer to role for documentation

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[cribl_server]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_cribl.yml`

## S3 Export

* Need to manually recover writelog role ARN and aws/s3 AWS managed key id in AWS Web console.

## References
* [juju4.cribl](https://github.com/juju4/ansible-cribl)
* S3 export
  * https://developer.hashicorp.com/terraform/tutorials/aws/aws-assumerole#review-iam-configuration
  * https://support.hashicorp.com/hc/en-us/articles/360041289933-Using-AWS-AssumeRole-with-the-AWS-Terraform-Provider
  * https://cribl.io/blog/setting-up-and-tuning-amazon-s3-as-a-cribl-stream-destination/
  * https://cribl.io/blog/securely-connecting-aws-s3-destination-to-cribl-cloud-and-hybrid-workers/
  * https://www.reddit.com/r/Terraform/comments/10g4z6s/create_selfassuming_selftrusting_iam_role/
