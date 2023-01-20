provider "aws" {
  region = var.primary_region
}

terraform {
  required_version = "~>1.3.7"
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
