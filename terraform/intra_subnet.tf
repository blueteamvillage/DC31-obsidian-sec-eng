############################################ Metrics server ############################################
resource "aws_security_group" "node_exporter_clients" {
  vpc_id      = module.vpc.vpc_id
  description = "metrics server security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_node_exporter_sg"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "allow_prometheus" {
  type              = "ingress"
  description       = "Allow Prometheus to consume metrics from node exporter"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.metrics.private_ip}/32"]
  security_group_id = aws_security_group.node_exporter_clients.id
}



resource "aws_security_group" "metrics" {
  vpc_id      = module.vpc.vpc_id
  description = "metrics server security group"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_metrics_sg"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "metrics_allow_ssh" {
  type              = "ingress"
  description       = "Allow SSH traffic from teleport"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.metrics.id
}

resource "aws_security_group_rule" "metrics_allow_http_from_teleport" {
  type              = "ingress"
  description       = "Allow HTTP traffic from teleport"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.metrics.id
}

resource "aws_security_group_rule" "metrics_allow_https_from_teleport" {
  type              = "ingress"
  description       = "Allow HTTPS traffic from teleport"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.metrics.id
}

resource "aws_security_group_rule" "metrics_allow_egress" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.metrics.id
}

resource "aws_instance" "metrics" {
  ami                    = var.ubunut-ami
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.intranet.id
  vpc_security_group_ids = [aws_security_group.metrics.id]
  key_name               = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip             = var.intranet_subnet_map["metrics"]

  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint          = "enabled"
    http_tokens            = "required"
  }

  root_block_device {
    volume_size           = 40
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_metrics_server"
    Project = var.PROJECT_PREFIX
    Team    = "sec_infra"
  }
}
