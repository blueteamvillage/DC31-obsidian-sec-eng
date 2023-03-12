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
    Name    = "${var.PROJECT_PREFIX}_WINDOWS_DOMAIN_CONTROLLER"
    Project = var.PROJECT_PREFIX
  }
}