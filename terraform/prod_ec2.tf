############################################ VULNERABLE WEB SERVER ############################################
resource "aws_security_group" "vuln_log4j_webserver" {
  vpc_id      = module.vpc.vpc_id
  description = "Vulnerable log4j webserver security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_VULNERABLE_LOG4J_WEB_SERVER_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "log4j_allow_ssh_from_teleport" {
  type              = "ingress"
  description       = "Allow SSH traffic from teleport"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.vuln_log4j_webserver.id
}

resource "aws_security_group_rule" "log4j_allow_http_from_teleport" {
  type              = "ingress"
  description       = "Allow HTTP traffic from teleport"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.vuln_log4j_webserver.id
}

resource "aws_security_group_rule" "log4j_allow_prometheus" {
  type              = "ingress"
  description       = "Allow Prometheus"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.metrics.private_ip}/32"]
  security_group_id = aws_security_group.vuln_log4j_webserver.id
}

resource "aws_security_group_rule" "log4j_allow_red_team" {
  for_each = var.red_team_subnet_map

  type              = "ingress"
  description       = "Allow red team boxes"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${aws_eip.red_team_servers_eips[each.key].public_ip}/32"]
  security_group_id = aws_security_group.vuln_log4j_webserver.id
}

resource "aws_security_group_rule" "log4j_allow_corp" {
  type              = "ingress"
  description       = "Allow corp network"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
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
  metadata_options {
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
