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

variable "intranet_subnet_map" {
  type = map(string)
  default = {
    "metrics" = "172.16.21.10",
  }
}

######################## Logging subnet ########################
variable "logging_cidr_block" {
  description = "CIDR block for Red Team subnet"
  type        = string
  default     = "172.16.22.0/24"
}

variable "logging_subnet_map" {
  type = map(string)
  default = {
    "cribl"              = "172.16.22.10",
    "splunk"             = "172.16.22.20",
    "securityonion"      = "172.16.22.23",
    "securityonion_bind" = "172.16.22.24",
    "velociraptor"       = "172.16.22.130",
    "jupyterhub"         = "172.16.22.150",
    "graylog"            = "172.16.22.170",
  }
}

variable "logging_ec2_size" {
  description = "Logging servers EC2 size"
  type        = string
  # testing
  # avoid going below t3.large or be wary of oom-killer
  default = "t3.large"
  # prod
  # default     = "r5.xlarge"
}

######################## Prod subnet ########################
variable "prod_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "172.16.40.0/24"
}

variable "prod_subnet_map" {
  type = map(string)
  default = {
    "webserver" = "172.16.40.100",
  }
}

######################## Corp subnet ########################
variable "corp_cidr_block" {
  description = "CIDR block for corp subnet"
  type        = string
  default     = "172.16.50.0/24"
}

variable "corp_subnet_map" {
  type = map(string)
  default = {
    "iot_eng_wkst" = "172.16.50.20"
    "win_dc"       = "172.16.50.100",
    "dockerserver" = "172.16.50.101",
    "mail"         = "172.16.50.102",
    "hmail"        = "172.16.50.103",
    "wkst01"       = "172.16.50.131",
    "wkst02"       = "172.16.50.132",
    "wkst03"       = "172.16.50.133",
    "wkst04"       = "172.16.50.134",
    "wkst05"       = "172.16.50.135",
    "wkst06"       = "172.16.50.136",
    "wkst07"       = "172.16.50.137",
    "wkst08"       = "172.16.50.138",
    "wkst09"       = "172.16.50.139",
    "wkst10"       = "172.16.50.140",
    "wkst11"       = "172.16.50.141",
    "wkst12"       = "172.16.50.142",
    "wkst13"       = "172.16.50.143",
    "wkst14"       = "172.16.50.144",
    "wkst15"       = "172.16.50.145",
    "wkst16"       = "172.16.50.146",
    "wkst17"       = "172.16.50.147",
    "wkst18"       = "172.16.50.148",
    "wkst19"       = "172.16.50.149",
    "wkst20"       = "172.16.50.150",
  }
}

######################## IoT subnet ########################
variable "iot_cidr_block" {
  description = "CIDR block for IoT subnet"
  type        = string
  default     = "172.16.60.0/24"
}

variable "iot_subnet_map" {
  type = map(string)
  default = {
    "iot_plc01"       = "172.16.60.11",
    "iot_plc02"       = "172.16.60.12",
    "iot_plc03"       = "172.16.60.13",
    "iot_plc04"       = "172.16.60.14",
    "iot_plc05"       = "172.16.60.15",
    "iot_plc06"       = "172.16.60.16",
    "iot_plc07"       = "172.16.60.17",
    "iot_plc08"       = "172.16.60.18",
    "iot_hmi_alpha"   = "172.16.60.200",
    "iot_hmi_beta"    = "172.16.60.201",
    "iot_hmi_charlie" = "172.16.60.202",
    "iot_hmi_delta"   = "172.16.60.203",
    "jhb01"           = "172.16.60.19"
  }
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
  default     = "ami-0ab0629dba5ae551d"
}
variable "ubuntu-so-ami" {
  # Ubuntu 20.04 as SO does not support 22.04 for now
  description = "Ubuntu 20.04 LTS AMI"
  type        = string
  default     = "ami-0568936c8d2b91c4e"
}
variable "windows-ami" {
  # Windows Server 2022
  # https://aws.amazon.com/marketplace/pp/prodview-bd6o47htpbnoe
  description = "Microsoft Windows Server 2022 Base"
  type        = string
  default     = "ami-0ae8d60635de460b2"
}

variable "securityonion-ami" {
  # https://aws.amazon.com/marketplace/pp/prodview-4gpqv3qlxq4ww?ref=_ptnr_soc_docs_210505
  description = "Security Onion 2"
  type        = string
  default     = ""
}
variable "windows_boxes_ec2_size" {
  description = "CIDR block for Red Team subnet"
  type        = string
  default     = "t3.medium"
}


######################## Route53 ########################
variable "project_base_domain" {
  description = "Route53 domain to use for Magnustempus Financial DNS records"
  type        = string
  default     = "magnumtempusfinancial.com"
}

variable "btv_route53_zone_id" {
  description = "Route53 Zone ID to use for Teleport DNS records"
  type        = string
  default     = "Z051379539VVT3OD13CSQ"
}

variable "btv_base_domain" {
  description = "Define the base domain for teleport to attach DNS records too"
  type        = string
  default     = "blueteamvillage.com"
}

######################## IoT - HMI ########################
variable "iot_hmi_ami" {
  # https://aws.amazon.com/marketplace/pp/prodview-u7kuv2lhucy6g?qid=1538086463719&sr=0-3&ref_=srh_res_product_title
  description = "AMI ID to use to use for base VM"
  type        = string
  default     = "ami-0b6a93e8289549df0"
}
