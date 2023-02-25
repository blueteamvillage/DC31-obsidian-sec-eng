################################ CORP DOCKER SERVER ##################################
resource "aws_security_group" "corp_docker_server" {
  vpc_id      = module.vpc.vgw_id
  description = "Corporate docker server security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_CORP_DOCKER_SERVER_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "corp_docker_allow_ingress_ssh" {
  type        = "ingress"
  description = "Allow inbound SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32"
  ]
  security_group_id = aws_security_group.corp_docker_server.id
}

resource "aws_security_group_rule" "corp_docker_allow_egress" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.corp_docker_server.id
}

resource "aws_instance" "corp_docker_server" {
  ami                    = var.ubunut-ami
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.corp.id
  vpc_security_group_ids = [aws_security_group.corp_docker_server.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = var.corp_subnet_map["dockerserver"]
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_CORP_DOCKER_SERVER"
    Project = var.PROJECT_PREFIX
  }
}
