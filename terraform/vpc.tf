############################################# Create VPC ############################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.PROJECT_PREFIX}_VPC"
  cidr = var.vpc_cidr_block

  azs             = ["${var.primary_zone}"]
  private_subnets = [var.private_cidr_block]
  public_subnets  = [var.public_cidr_block]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Project = var.PROJECT_PREFIX
  }
}

############################################# Intranet subnet #############################################
resource "aws_subnet" "intranet" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.intranet_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.primary_zone

  tags = {
    Name    = "${var.PROJECT_PREFIX}_intranet_subnet"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route_table_association" "intranet" {
  subnet_id      = aws_subnet.intranet.id
  route_table_id = module.vpc.private_route_table_ids[0]
}

############################################# Red team subnet #############################################
resource "aws_subnet" "red_team" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.red_team_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.primary_zone

  tags = {
    Name    = "${var.PROJECT_PREFIX}_red_team_subnet"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route_table_association" "red_team" {
  subnet_id      = aws_subnet.red_team.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

############################################# Prod subent #############################################
resource "aws_subnet" "prod" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.prod_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.primary_zone

  tags = {
    Name    = "${var.PROJECT_PREFIX}_prod_subnet"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route_table_association" "prod" {
  subnet_id      = aws_subnet.prod.id
  route_table_id = module.vpc.public_route_table_ids[0]
}


############################################# Corp subnet #############################################
resource "aws_subnet" "corp" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.corp_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.primary_zone

  tags = {
    Name    = "${var.PROJECT_PREFIX}_corp_subnet"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route_table_association" "corp" {
  subnet_id      = aws_subnet.corp.id
  route_table_id = module.vpc.private_route_table_ids[0]
}


############################################# IoT subnet #############################################
resource "aws_subnet" "iot" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.iot_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.primary_zone

  tags = {
    Name    = "${var.PROJECT_PREFIX}_iot_subnet"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route_table_association" "iot" {
  subnet_id      = aws_subnet.iot.id
  route_table_id = module.vpc.private_route_table_ids[0]
}

############################################# Monitoring/logging subnet #############################################
resource "aws_subnet" "logging" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.logging_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.primary_zone

  tags = {
    Name    = "${var.PROJECT_PREFIX}_loggin_subnet"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route_table_association" "loggin" {
  subnet_id      = aws_subnet.logging.id
  route_table_id = module.vpc.public_route_table_ids[0]
}
