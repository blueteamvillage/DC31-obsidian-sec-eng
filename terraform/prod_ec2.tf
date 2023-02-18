############################################ VULNERABLE WEB SERVER ############################################
resource "aws_security_group" "vuln_log4j_webserver" {
  vpc_id      = module.vpc.vgw_id
  description = "Vulnerable log4j webserver security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_VULNERABLE_LOG4J_WEB_SERVER_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "log4j_allow_http_from_corp" {
  type              = "ingress"
  description       = "Allow HTTP traffic from corp"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.corp_cidr_block]
  security_group_id = aws_security_group.vuln_log4j_webserver.id
}


resource "aws_security_group_rule" "log4j_allow_egress" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vuln_log4j_webserver.id
}

resource "aws_instance" "vuln_log4j_webserver" {
  ami                    = var.ubunut-ami
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.prod.id
  vpc_security_group_ids = [aws_security_group.vuln_log4j_webserver.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = var.prod_subnet_map["webserver"]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_VULNERABLE_DMZ_WEB_SERVER"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_eip" "vuln_log4j_webserver" {
  instance = aws_instance.vuln_log4j_webserver.id
  vpc      = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_VULNERABLE_LOG4J_WEB_SERVER_eip"
    Project = var.PROJECT_PREFIX
  }
}
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
      "18.218.136.118/32",
      "172.16.10.183/32",
      "${var.corp_cidr_block}"
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "18.218.136.118/32",
      "172.16.10.183/32",
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
  name = "win_domain_admin_passwd"
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
  get_password_data       = true
  disable_api_termination = true
  user_data               = data.template_file.password_change.rendered

  root_block_device {
    volume_size           = 60
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
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
    Name    = "${var.PROJECT_PREFIX}_WINDOWS_DOMAIN_CONTROLLER"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_instance" "windows_domain_controller_vuln" {
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
    Name    = "${var.PROJECT_PREFIX}_VULN_WINDOWS_DOMAIN_CONTROLLER"
    Project = var.PROJECT_PREFIX
  }
}
