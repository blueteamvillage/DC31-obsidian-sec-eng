# Proxy

If you sit behind a proxy, the following domains are needed at minimum.
Add an entry for any S3 bucket you want to access.
```
teleport.blueteamvillage.com
# ansible
ec2.us-east-2.amazonaws.com
s3.amazonaws.com
defcon-2023-obsidian-teleport-kxl6y.s3.amazonaws.com
defcon-2023-obsidian-teleport-kxl6y.s3.us-east-2.amazonaws.com
# terraform
registry.terraform.io
releases.hashicorp.com
sts.amazonaws.com
sts.us-east-2.amazonaws.com
defcon-terraform-state-mr8ba.s3.us-east-2.amazonaws.com
dynamodb.us-east-2.amazonaws.com
iam.amazonaws.com
secretsmanager.us-east-2.amazonaws.com
checkpoint-api.hashicorp.com
route53.amazonaws.com
```
