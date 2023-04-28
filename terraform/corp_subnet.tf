############################################ Windows Domain Controller ############################################
# Create Security group for corporate hosts
resource "aws_security_group" "win_dc_sg" {
  vpc_id = module.vpc.vpc_id

  # Allow ICMP, RDP, & WinRM from management subnet
  ingress {
    from_port = 8
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = [
      "${module.teleport.public_ip_addr}/32",
      "${module.teleport.private_ip_addr}/32",
      "${var.corp_cidr_block}"
    ]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.metrics.private_ip}/32"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "${module.teleport.public_ip_addr}/32",
      "${module.teleport.private_ip_addr}/32",
      "${var.corp_cidr_block}",
      var.prod_cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_WIN_DC_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "random_password" "win_domain_admin_random_passwd_gen" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "win_domain_admin_passwd" {
  name = "${var.PROJECT_PREFIX}_win_domain_admin_passwd"
  tags = {
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_secretsmanager_secret_version" "database_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.win_domain_admin_passwd.id
  secret_string = random_password.win_domain_admin_random_passwd_gen.result
}

data "template_file" "password_change" {
  template = file("templates/tf_windows_setup.ps1")

  vars = {
    windows_admin_password = random_password.win_domain_admin_random_passwd_gen.result
  }
}

resource "aws_instance" "windows_domain_controller" {
  ami                     = var.windows-ami
  instance_type           = "t3.medium"
  subnet_id               = aws_subnet.corp.id
  vpc_security_group_ids  = [aws_security_group.win_dc_sg.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.corp_subnet_map["win_dc"]
  disable_api_termination = true
  user_data               = data.template_file.password_change.rendered

  root_block_device {
    volume_size           = 60
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.PROJECT_PREFIX}_WINDOWS_DOMAIN_CONTROLLER"
    Project     = var.PROJECT_PREFIX
    Environment = "corp"
  }
}

############################################ IOT ENG Workstation ############################################
resource "aws_security_group" "iot_eng_wkst_sg" {
  vpc_id      = module.vpc.vpc_id
  description = "Windows IOT Engineering workstation security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_iot_eng_wkst_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "iot_eng_wkst_allow_teleport" {
  type              = "ingress"
  description       = "Allow Teleport"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.iot_eng_wkst_sg.id
}

resource "aws_security_group_rule" "iot_eng_wkst_allow_icmp" {
  type        = "ingress"
  description = "Allow ICMP"
  from_port   = 8
  to_port     = 0
  protocol    = "icmp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    "${var.corp_cidr_block}"
  ]
  security_group_id = aws_security_group.iot_eng_wkst_sg.id
}

resource "aws_security_group_rule" "iot_eng_wkst_allow_corp" {
  type              = "ingress"
  description       = "Allow corp traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.corp_cidr_block]
  security_group_id = aws_security_group.iot_eng_wkst_sg.id
}

resource "aws_security_group_rule" "iot_eng_wkst_allow_prod" {
  type              = "ingress"
  description       = "Allow prod traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.prod_cidr_block]
  security_group_id = aws_security_group.iot_eng_wkst_sg.id
}

resource "aws_security_group_rule" "iot_eng_wkst_egress" {
  type              = "egress"
  description       = "Allow egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iot_eng_wkst_sg.id
}

resource "aws_instance" "iot_eng_wkst" {
  ami           = var.windows-ami
  instance_type = var.windows_boxes_ec2_size
  subnet_id     = aws_subnet.corp.id
  vpc_security_group_ids = [
    aws_security_group.iot_eng_wkst_sg.id,
    aws_security_group.node_exporter_clients.id,
  ]
  key_name   = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip = var.corp_subnet_map["iot_eng_wkst"]
  user_data  = data.template_file.password_change.rendered

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
    Environment = "corp"
  }
}


################################ Mail server ##################################
resource "aws_security_group" "corp_mail_server" {
  vpc_id      = module.vpc.vpc_id
  description = "Corporate Mail server security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_corp_mail_SERVER_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "corp_mail_allow_teleport" {
  type        = "ingress"
  description = "Allow inbound SSH"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32"
  ]
  security_group_id = aws_security_group.corp_mail_server.id
}

resource "aws_security_group_rule" "corp_mail_allow_corp_subnet" {
  type              = "ingress"
  description       = "Allow wiki web access from teleport"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.corp_cidr_block]
  security_group_id = aws_security_group.corp_mail_server.id
}

resource "aws_security_group_rule" "corp_mail_allow_prometheus" {
  type        = "ingress"
  description = "Allow Prometheus to access node exporter"
  from_port   = 9100
  to_port     = 9100
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    "${aws_instance.metrics.private_ip}/32"
  ]
  security_group_id = aws_security_group.corp_mail_server.id
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "corp_mail_allow_egress" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.corp_mail_server.id
}

resource "aws_instance" "corp_mail_server" {
  ami                    = var.ubunut-ami
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.corp.id
  vpc_security_group_ids = [aws_security_group.corp_mail_server.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = var.corp_subnet_map["mail"]

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_corp_mail_SERVER"
    Project = var.PROJECT_PREFIX
  }
}
