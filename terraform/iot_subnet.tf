############################################ PLCs ############################################
resource "aws_security_group" "iot_plc_servers" {
  vpc_id      = module.vpc.vpc_id
  description = "IoT01 server security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_IOT01_SERVER_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "iot_plc_allow_ingress_ssh" {
  type        = "ingress"
  description = "Allow inbound SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32"
  ]
  security_group_id = aws_security_group.iot_plc_servers.id
}

resource "aws_security_group_rule" "iot_plc_allow_inbound_from_iot" {
  type              = "ingress"
  description       = "Allow inbound from corp"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [var.iot_cidr_block]
  security_group_id = aws_security_group.iot_plc_servers.id
}

resource "aws_security_group_rule" "iot_plc_allow_egress" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iot_plc_servers.id
}

resource "aws_instance" "iot_plc_servers" {
  # https://regex101.com/r/9Q7UBi/1
  for_each = {
    for k, v in var.iot_subnet_map : k => v
    if can(regex("iot_plc.*", k))
  }

  ami           = var.ubunut-ami
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.iot.id
  vpc_security_group_ids = [
    aws_security_group.iot_plc_servers.id,
    aws_security_group.node_exporter_clients.id,
  ]
  key_name   = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip = each.value

  metadata_options {
    # https://github.com/hashicorp/terraform-provider-aws/issues/12564
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name        = "${var.PROJECT_PREFIX}_${each.key}_server"
    Project     = var.PROJECT_PREFIX
    Environment = "iot"
    IOTtype     = "plc"
  }

}

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
  description       = "Allow all traffic from IoT network"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [var.iot_cidr_block]
  security_group_id = aws_security_group.iot_hmi_servers.id
}

resource "aws_security_group_rule" "allow_tomcat_from_teleport" {
  type              = "ingress"
  description       = "Allow Tomcat/ScadaBR from Teleport"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
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
  # https://regex101.com/r/9Q7UBi/1
  for_each = {
    for k, v in var.iot_subnet_map : k => v
    if can(regex("iot_hmi.*", k))
  }

  ami           = var.iot_hmi_ami
  instance_type = "t3.small"
  subnet_id     = aws_subnet.iot.id
  vpc_security_group_ids = [
    aws_security_group.iot_hmi_servers.id,
    aws_security_group.node_exporter_clients.id,
  ]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = each.value
  disable_api_termination = true
  user_data               = data.template_file.password_change.rendered

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
    IOTtype     = "hmi"
  }
}
############################################ IOT Jump Host ############################################
resource "aws_security_group" "iot_jump_box_sg" {
  vpc_id = module.vpc.vpc_id

  # Allow ICMP, RDP, & WinRM from management subnet, and the corp subnet
  ingress {
    from_port = 8
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
      "${var.corp_cidr_block}"
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      #teleport internal and external IP.
      "${module.teleport.private_ip_addr}/32",
      "${var.corp_cidr_block}",
    ]
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_iot_jump_box_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_instance" "iot_jump_box" {
  ami                    = var.windows-ami
  instance_type          = var.windows_boxes_ec2_size
  subnet_id              = aws_subnet.iot.id
  vpc_security_group_ids = [aws_security_group.iot_jump_box_sg.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = var.iot_subnet_map["jhb01"]
  get_password_data      = true
  user_data              = data.template_file.password_change.rendered

  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_state,
    ]
  }
  ############# IGNORE instance type ###############
  ################## DO NOT TOUCH ##################

  tags = {
    Name        = "${var.PROJECT_PREFIX}_IOT_JUMPHOST_SERVER"
    Project     = var.PROJECT_PREFIX
    Environment = "IOT"
  }
}

############################################ IOT ENG Workstation ############################################
resource "aws_security_group" "iot_eng_wkst_sg" {
  vpc_id = module.vpc.vpc_id

  # Allow ICMP, RDP, & WinRM from management subnet, and the corp subnet
  ingress {
    from_port = 8
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
      "${var.corp_cidr_block}"
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      #teleport internal and external IP.
      "${module.teleport.private_ip_addr}/32",
    ]
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_iot_eng_wkst_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_instance" "iot_eng_wkst" {
  ami                    = var.windows-ami
  instance_type          = var.windows_boxes_ec2_size
  subnet_id              = aws_subnet.iot.id
  vpc_security_group_ids = [aws_security_group.iot_eng_wkst_sg.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = var.iot_subnet_map["iot_eng_wkst"]
  get_password_data      = true
  user_data              = data.template_file.password_change.rendered

  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_state,
    ]
  }
  ############# IGNORE instance type ###############
  ################## DO NOT TOUCH ##################

  tags = {
    Name        = "${var.PROJECT_PREFIX}_iot_eng_wkst"
    Project     = var.PROJECT_PREFIX
    Environment = "IOT"
  }
}
