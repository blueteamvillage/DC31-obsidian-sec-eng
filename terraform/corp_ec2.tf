############################################ Windows client - A ############################################
resource "aws_security_group" "win_clients_sg" {
  vpc_id = module.vpc.vpc_id

  # Allow ICMP, RDP, & WinRM from management subnet
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
    Name    = "${var.PROJECT_PREFIX}_WIN_CLIENTS_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_instance" "windows_clients" {
  #this magically loops through and creates... 3 boxes.
  for_each = {
    for k, v in var.corp_subnet_map : k => v
    if length(regexall("win_client\\d+", k)) > 0
  }

  ami                    = var.windows-ami
  instance_type          = var.windows_boxes_ec2_size
  subnet_id              = aws_subnet.corp.id
  vpc_security_group_ids = [aws_security_group.win_clients_sg.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = each.value
  get_password_data      = true
  user_data              = data.template_file.password_change.rendered

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
    Name    = "${var.PROJECT_PREFIX}_${upper(each.key)}"
    Project = var.PROJECT_PREFIX
  }
}
