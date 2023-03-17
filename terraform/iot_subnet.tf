############################################ HMIs ############################################
resource "aws_security_group" "iot_hmi_servers" {
  vpc_id      = module.vpc.vpc_id
  description = "Windows 2012 Servers HMIs security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_iot_hmi_servers_sg2"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "allow_rdp_from_teleport" {
  type        = "ingress"
  description = "Allow RDP from Teleport"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    "${module.teleport.public_ip_addr}/32",
  ]
  security_group_id = aws_security_group.iot_hmi_servers.id
}

resource "aws_security_group_rule" "allow_winrm_from_teleport" {
  type        = "ingress"
  description = "Allow WinRM(s) from Teleport"
  from_port   = 5965
  to_port     = 5986
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    "${module.teleport.public_ip_addr}/32",
  ]
  security_group_id = aws_security_group.iot_hmi_servers.id
}

resource "aws_security_group_rule" "allow_all_traffic_from_iot_subnet" {
  type              = "ingress"
  description       = "Allow VNC connections from IoT network"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [var.iot_cidr_block]
  security_group_id = aws_security_group.iot_hmi_servers.id
}

resource "aws_security_group_rule" "iot_hmi_servers_allow_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iot_hmi_servers.id
}

resource "aws_instance" "iot_hmi_servers" {
  for_each = var.iot_subnet_map

  ami                     = var.iot_hmi_ami
  instance_type           = "t3.small"
  subnet_id               = aws_subnet.iot.id
  vpc_security_group_ids  = [aws_security_group.iot_hmi_servers.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = each.value
  disable_api_termination = true

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  root_block_device {
    volume_size           = 40
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.PROJECT_PREFIX}_${each.key}_server"
    Project     = var.PROJECT_PREFIX
    Environment = "iot"
  }
}
