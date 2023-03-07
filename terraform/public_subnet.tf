############################################ Logging/Cribl Server ############################################
resource "aws_security_group" "cribl_server_sg2" {
  vpc_id      = module.vpc.vpc_id
  description = "Cribl security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_cribl_server_sg2"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "cribl_allow_ssh" {
  type        = "ingress"
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32"
  ]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_http" {
  type        = "ingress"
  description = "Allow HTTP/9000 from corp subnets, web server, and corp subnet NAT gateway for cribl networking - Cribl Web UI"
  from_port   = 9000
  to_port     = 9000
  protocol    = "tcp"
  cidr_blocks = [
    # cribl needs to call itself
    "${aws_eip.cribl_server_eip.public_ip}/32",
    var.corp_cidr_block,
    # "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_instance" "cribl_server" {
  ami                     = var.ubunut-ami
  instance_type           = var.logging_ec2_size
  subnet_id               = aws_subnet.logging.id
  vpc_security_group_ids  = [aws_security_group.cribl_server_sg2.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.logging_subnet_map["cribl"]
  disable_api_termination = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 150
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_type,
      cpu_core_count,
      ebs_optimized,
    ]
  }
  ############# IGNORE instance type ###############
  ################## DO NOT TOUCH ##################

  tags = {
    Name    = "${var.PROJECT_PREFIX}_cribl_server"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_eip" "cribl_server_eip" {
  instance = aws_instance.cribl_server.id
  vpc      = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_cribl_server_eip"
    Project = var.PROJECT_PREFIX
  }
}

############################################ Logging/SecurityOnion Server ############################################
resource "aws_security_group" "securityonion_server_sg2" {
  vpc_id      = module.vpc.vpc_id
  description = "SecurityOnion security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_securityonion_server_sg2"
    Project = var.PROJECT_PREFIX
  }

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${module.teleport.private_ip_addr}/32"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${module.teleport.private_ip_addr}/32"]
  }

  # HTTP port for Web UI
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
    ]
  }

  # HTTPS port for Web UI
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "securityonion_server" {
  ami           = var.ubunut-ami
  instance_type = "t3.medium"
  # Docs prod recommendation - https://docs.securityonion.net/en/2.3/cloud-ami.html
  # instance_type           = "t3a.xlarge"
  subnet_id               = aws_subnet.logging.id
  vpc_security_group_ids  = [aws_security_group.securityonion_server_sg2.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.logging_subnet_map["securityonion"]
  disable_api_termination = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 150
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_type,
      cpu_core_count,
      ebs_optimized,
    ]
  }
  ############# IGNORE instance type ###############
  ################## DO NOT TOUCH ##################

  tags = {
    Name    = "${var.PROJECT_PREFIX}_securityonion_server"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_eip" "securityonion_server_eip" {
  instance = aws_instance.securityonion_server.id
  vpc      = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_securityonion_server_eip"
    Project = var.PROJECT_PREFIX
  }
}

############################################ Red team boxes ############################################
resource "aws_security_group" "red_team_servers" {
  vpc_id      = module.vpc.vpc_id
  description = "Cribl security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_cribl_server_sg2"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "allow_ssh_from_teleport" {
  type        = "ingress"
  description = "Allow SSH from Teleport"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    "${module.teleport.public_ip_addr}/32",
  ]
  security_group_id = aws_security_group.red_team_servers.id
}

resource "aws_security_group_rule" "allow_inbound_from_nat_gateway" {
  type        = "ingress"
  description = "Allow all traffic from NAT gateway"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [
    "${module.vpc.nat_public_ips[0]}/32",
  ]
  security_group_id = aws_security_group.red_team_servers.id
}

resource "aws_security_group_rule" "allow_inbound_from_log4j" {
  type        = "ingress"
  description = "Allow all traffic from log4j"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [
    "${aws_eip.vuln_log4j_webserver.public_ip}/32",
  ]
  security_group_id = aws_security_group.red_team_servers.id
}

resource "aws_instance" "red_team_servers" {
  for_each = var.red_team_subnet_map

  ami                     = var.ubunut-ami
  instance_type           = "t3.small"
  subnet_id               = module.vpc.public_subnets[0]
  vpc_security_group_ids  = [aws_security_group.red_team_servers.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = each.value
  disable_api_termination = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.PROJECT_PREFIX}_${each.key}_server"
    Project     = var.PROJECT_PREFIX
    Environment = "red_team"
  }
}

resource "aws_eip" "red_team_servers_eips" {
  for_each = var.red_team_subnet_map

  #aws_instance.red_team_servers["red_team_box_charlie"]
  instance = aws_instance.red_team_servers[each.key].id
  vpc      = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_${each.key}_server_eip"
    Project = var.PROJECT_PREFIX
  }
}
