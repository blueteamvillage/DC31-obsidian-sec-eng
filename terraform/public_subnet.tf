############################################ Logging/Cribl Server ############################################
resource "aws_security_group" "cribl_server_sg2" {
  vpc_id = aws_vpc.vpc.id
  description = "Cribl security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_cribl_server_sg2"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "cribl_allow_http" {
  type = "ingress"
  description = "Allow HTTP/9000 from jumpbox, corp + dmz subnets, web server, and corp subnet NAT gateway for cribl networking - Cribl Web UI"
  from_port = 9000
  to_port = 9000
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.jump_box.private_ip}/32",
    "${aws_eip.VULNERABLE_DMZ_WEB_SERVER_eip.public_ip}/32",
    "${aws_eip.DMZ_RDP_SERVER_eip.public_ip}/32",
    "${aws_eip.nat_gw_eip.public_ip}/32",
    # cribl needs to call itself
    "${aws_eip.cribl_server_eip.public_ip}/32",
    var.corp_cidr_block,
    var.dmz_cidr_block,
    # "0.0.0.0/0"
  ]
  security_group_id = "${aws_security_group.cribl_server_sg2.id}"
}


resource "aws_security_group_rule" "cribl_allow_ssh" {
  type = "ingress"
  description = "Allow SSH from jumpbox"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  security_group_id = "${aws_security_group.cribl_server_sg2.id}"
}

resource "aws_security_group_rule" "cribl_allow_ping" {
  type = "ingress"
  description       = "Allow ICMP from jumpbox"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["${aws_instance.jump_box.private_ip}/32"]
  security_group_id = "${aws_security_group.cribl_server_sg2.id}"
}

resource "aws_security_group_rule" "cribl_allow_prometheus" {
  type = "ingress"
  description = "Allow Prometheus to access node exporter"
  from_port = 9100
  to_port = 9100
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.jump_box.private_ip}/32",
    "${aws_instance.metrics_server.private_ip}/32"
  ]
  security_group_id = "${aws_security_group.cribl_server_sg2.id}"
}

resource "aws_security_group_rule" "cribl_allow_egress" {
  type = "egress"
  description = "Allow all outbound traffic"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.cribl_server_sg2.id}"
}

resource "aws_instance" "cribl_server" {
  ami                     = var.ubunut-ami
  instance_type           = "r5.xlarge"
  subnet_id               = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.cribl_server_sg2.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.public_subnet_map["cribl"]
  disable_api_termination = true

  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_type,
      instance_state,
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

resource "aws_route53_record" "cribl" {
  zone_id = var.public_domain_zone_id
  name    = "cribl.magnumtempusfinancial.com"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.cribl_server_eip.public_ip]
}
