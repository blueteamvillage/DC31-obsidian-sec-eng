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

resource "aws_security_group_rule" "red_team_servers_allow_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.red_team_servers.id
}

resource "aws_instance" "red_team_servers" {
  for_each = var.red_team_subnet_map

  ami                     = var.ubunut-ami
  instance_type           = "t3.small"
  subnet_id               = aws_subnet.red_team.id
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
