provider "aws" {
  region = var.primary_region
}

terraform {
  required_version = "1.3.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.51.0"
    }
  }
}

#########################################
#          DO NOT TOUCH
# Make use of the S3 remote state
#          DO NOT TOUCH
#########################################
terraform {
  backend "s3" {
    bucket         = "defcon-terraform-state-mr8ba"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "defcon-terraform-state-mr8ba"
    encrypt        = true
  }
}

#########################################
# Add SSH keys
#########################################
# https://www.bogotobogo.com/DevOps/Terraform/Terraform-parameters-variables.php
resource "aws_key_pair" "deployer" {
  key_name   = "${var.PROJECT_PREFIX}-ssh-key"
  public_key = file(var.public_key)
  tags = {
    Name    = "${var.PROJECT_PREFIX}_test_box"
    Project = var.PROJECT_PREFIX
  }
}

module "teleport" {
  source = "github.com/blueteamvillage/btv-sec-eng-teleport-cluster/terraform"

  #### General ####
  PROJECT_PREFIX  = var.PROJECT_PREFIX
  primary_region  = var.primary_region
  public_key_name = aws_key_pair.deployer.key_name

  #### Route53 ####
  route53_zone_id = var.teleport_route53_zone_id
  route53_domain  = var.teleport_base_domain

  #### VPC ####
  vpc_id             = module.vpc.vpc_id
  teleport_subnet_id = module.vpc.public_subnets[0]
}
