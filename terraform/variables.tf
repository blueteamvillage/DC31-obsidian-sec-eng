variable "PROJECT_PREFIX" {
  description = "Prefix that is appended to all resources"
  type        = string
  default     = "DEFCON_2023_OBSIDIAN"
}

variable "vpc_cidr_block" {
  description = "CIDR of VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "primary_region" {
  description = "Primary region to create resources in"
  type        = string
  default     = "us-east-2"
}

variable "primary_zone" {
  description = "Primary availability zone to create resources in"
  type        = string
  default     = "us-east-2b"
}

variable "public_key" {
  description = "Location of public key for provisioning EC2s"
  type        = string
  default     = "ssh_keys/id_ed25519.pub"
}

######################## Public subnet ########################
variable "public_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "172.16.10.0/24"
}

variable "public_subnet_map" {
  type = map(string)
  default = {
    "teleport" = "172.16.10.100",
  }
}

######################## Private subnet ########################
variable "private_cidr_block" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "172.16.11.0/24"
}

######################## Intranet ########################
variable "intranet_cidr_block" {
  description = "CIDR block for intranet/sec-infra subnet"
  type        = string
  default     = "172.16.21.0/24"
}

######################## Logging subnet ########################
variable "logging_cidr_block" {
  description = "CIDR block for Red Team subnet"
  type        = string
  default     = "172.16.22.0/24"
}

######################## Prod subnet ########################
variable "prod_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "172.16.40.0/24"
}

######################## Corp subnet ########################
variable "corp_cidr_block" {
  description = "CIDR block for corp subnet"
  type        = string
  default     = "172.16.50.0/24"
}

######################## IoT subnet ########################
variable "iot_cidr_block" {
  description = "CIDR block for IoT subnet"
  type        = string
  default     = "172.16.60.0/24"
}

######################## Red team subnet ########################
variable "red_team_cidr_block" {
  description = "CIDR block for Red Team subnet"
  type        = string
  default     = "172.16.181.0/24"
}

variable "red_team_subnet_map" {
  type = map(string)
  default = {
    "red_team_box_alpha"   = "172.16.181.200",
    "red_team_box_beta"    = "172.16.181.201",
    "red_team_box_charlie" = "172.16.181.202"
  }
}

variable "ubunut-ami" {
  # Ubuntu 22.04
  # https://cloud-images.ubuntu.com/locator/ec2/
  description = "Ubuntu 22.04 LTS AMI"
  type        = string
  default     = "ami-0d09654d0a20d3ae2"
}

variable "windows-ami" {
  # Windows Sever 2022
  # https://aws.amazon.com/marketplace/pp/prodview-bd6o47htpbnoe
  description = "Microsoft Windows Server 2022 Base"
  type        = string
  default     = "ami-0ae8d60635de460b2"
}