############################################ Windows client - A ############################################
resource "aws_security_group" "win_clients_sg" {
  vpc_id      = module.vpc.vpc_id
  description = "Windows corp clients security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_WIN_CLIENTS_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "win_client_allow_inbound" {
  type        = "ingress"
  description = "Allow ALL inbound from teleport, corp, prod"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
    var.prod_cidr_block,
  ]
  security_group_id = aws_security_group.win_clients_sg.id
}

resource "aws_security_group_rule" "win_client_allow_rdp" {
  type        = "ingress"
  description = "Allow inbound RDP"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
  ]
  security_group_id = aws_security_group.win_clients_sg.id
}

resource "aws_security_group_rule" "win_client_allow_winrm" {
  type        = "ingress"
  description = "Allow inbound WinRM"
  from_port   = 5985
  to_port     = 5986
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
  ]
  security_group_id = aws_security_group.win_clients_sg.id
}

resource "aws_security_group_rule" "win_client_allow_icmp" {
  type              = "ingress"
  description       = "Allow ICMP ping requests from anywhere"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.win_clients_sg.id
}

resource "aws_security_group_rule" "win_client_allow_outbound" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.win_clients_sg.id
}


resource "aws_instance" "windows_clients" {
  #this magically loops through and creates... 3 boxes.
  # https://regex101.com/r/l1MKdn/1
  for_each = {
    for k, v in var.corp_subnet_map : k => v
    if can(regex("wkst.*", k))
  }

  ami           = var.windows-ami
  instance_type = var.windows_boxes_ec2_size
  subnet_id     = aws_subnet.corp.id
  vpc_security_group_ids = [
    aws_security_group.win_clients_sg.id,
    aws_security_group.node_exporter_clients.id,
  ]
  key_name   = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip = each.value
  user_data  = data.template_file.password_change.rendered

  root_block_device {
    volume_size           = 60
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.PROJECT_PREFIX}_${upper(each.key)}"
    Project     = var.PROJECT_PREFIX
    Environment = "corp"
  }
}
