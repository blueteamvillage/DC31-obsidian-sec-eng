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
