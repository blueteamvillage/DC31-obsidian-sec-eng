############################################ Velociraptor Server ############################################
resource "aws_security_group" "velociraptor_server_sg2" {
  vpc_id      = module.vpc.vpc_id
  description = "Velociraptor security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_velociraptor_server_sg2"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "velociraptor_allow_http" {
  type        = "ingress"
  description = "Allow HTTP from jumpbox, corp + dmz subnets, web server, and corp subnet NAT gateway for Velociraptor networking"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [
    # velociraptor needs to call itself
    "${aws_eip.velociraptor_server_eip.public_ip}/32",
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
    var.public_cidr_block,
    var.private_cidr_block,
    var.intranet_cidr_block,
    var.logging_cidr_block,
    var.prod_cidr_block,
    var.iot_cidr_block,
    var.red_team_cidr_block,
    # during initial setup and cert renewal, need to temporarily open to get public certificate with certbot
    # else line should be commented
    # `terraform apply -target=aws_security_group_rule.velociraptor_allow_https -target=aws_security_group_rule.velociraptor_allow_http`
    # https://certbot.eff.org/faq#what-ip-addresses-will-the-let-s-encrypt-servers-use-to-validate-my-web-server
    # "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.velociraptor_server_sg2.id
}

resource "aws_security_group_rule" "velociraptor_allow_https" {
  type        = "ingress"
  description = "Allow HTTPS from jumpbox, corp + dmz subnets, web server, and corp subnet NAT gateway for Velociraptor networking"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [
    # velociraptor needs to call itself
    "${aws_eip.velociraptor_server_eip.public_ip}/32",
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
    var.public_cidr_block,
    var.private_cidr_block,
    var.intranet_cidr_block,
    var.logging_cidr_block,
    var.prod_cidr_block,
    var.iot_cidr_block,
    var.red_team_cidr_block,
    # during initial setup and cert renewal, need to temporarily open to get public certificate with certbot
    # else line should be commented
    # "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.velociraptor_server_sg2.id
}

resource "aws_security_group_rule" "velociraptor_allow_ssh" {
  type        = "ingress"
  description = "Allow SSH from jumpbox"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
  ]
  security_group_id = aws_security_group.velociraptor_server_sg2.id
}

resource "aws_security_group_rule" "velociraptor_allow_ping" {
  type        = "ingress"
  description = "Allow ICMP from jumpbox"
  from_port   = 8
  to_port     = 0
  protocol    = "icmp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
  ]
  security_group_id = aws_security_group.velociraptor_server_sg2.id
}

resource "aws_security_group_rule" "velociraptor_allow_prometheus" {
  type        = "ingress"
  description = "Allow Prometheus to access node exporter"
  from_port   = 9100
  to_port     = 9100
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    "${aws_instance.metrics.private_ip}/32"
  ]
  security_group_id = aws_security_group.velociraptor_server_sg2.id
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "velociraptor_allow_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.velociraptor_server_sg2.id
}

resource "aws_instance" "velociraptor_server" {
  ami                     = var.ubunut-ami
  instance_type           = "r5.xlarge"
  subnet_id               = aws_subnet.logging.id
  vpc_security_group_ids  = [aws_security_group.velociraptor_server_sg2.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.logging_subnet_map["velociraptor"]
  disable_api_termination = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_type,
      cpu_core_count,
      ebs_optimized,
    ]
  }
  ############# IGNORE instance type ###############
  ################## DO NOT TOUCH ##################

  tags = {
    Name    = "${var.PROJECT_PREFIX}_velociraptor_server"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_eip" "velociraptor_server_eip" {
  instance = aws_instance.velociraptor_server.id
  vpc      = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_velociraptor_server_eip"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_route53_record" "velociraptor" {
  zone_id = var.teleport_route53_zone_id
  name    = "velociraptor.teleport.${var.teleport_base_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.velociraptor_server_eip.public_ip]
}

############################################ Logging/Cribl Server ############################################
resource "aws_security_group" "cribl_server_sg2" {
  vpc_id      = module.vpc.vpc_id
  description = "Cribl security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_cribl_server_sg2"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "cribl_allow_ssh" {
  type        = "ingress"
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32"
  ]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_ping" {
  type        = "ingress"
  description = "Allow ICMP pings from all subnets"
  from_port   = 0
  to_port     = 0
  protocol    = "icmp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
    var.public_cidr_block,
    var.private_cidr_block,
    var.intranet_cidr_block,
    var.logging_cidr_block,
    var.prod_cidr_block,
    var.iot_cidr_block,
    var.red_team_cidr_block,
  ]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_9200" {
  type        = "ingress"
  description = "Allow elasticsearch tcp/9200"
  from_port   = 9200
  to_port     = 9200
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    var.corp_cidr_block,
    var.public_cidr_block,
    var.private_cidr_block,
    var.intranet_cidr_block,
    var.logging_cidr_block,
    var.prod_cidr_block,
    var.iot_cidr_block,
    var.red_team_cidr_block,
  ]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_http" {
  type        = "ingress"
  description = "Allow HTTP/9000 from corp subnets, web server, and corp subnet NAT gateway for cribl networking - Cribl Web UI"
  from_port   = 9000
  to_port     = 9000
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    # cribl needs to call itself
    "${aws_eip.cribl_server_eip.public_ip}/32",
    var.corp_cidr_block,
    # "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_prometheus" {
  type              = "ingress"
  description       = "Allow Prometheus"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.metrics.private_ip}/32"]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_security_group_rule" "cribl_allow_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cribl_server_sg2.id
}

resource "aws_instance" "cribl_server" {
  ami                     = var.ubunut-ami
  instance_type           = var.logging_ec2_size
  subnet_id               = aws_subnet.logging.id
  vpc_security_group_ids  = [aws_security_group.cribl_server_sg2.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.logging_subnet_map["cribl"]
  disable_api_termination = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 150
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_type,
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

############################################ Splunk SIEM ############################################
resource "aws_security_group" "splunk_server_sg" {
  vpc_id      = module.vpc.vpc_id
  description = "Splunk server security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_splunk_SERVER_SG"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_security_group_rule" "splunk_allow_icmp_from_jumpbox" {
  type              = "ingress"
  description       = "Allow ICMP from Teleport"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.splunk_server_sg.id
}

resource "aws_security_group_rule" "splunk_allow_ssh_from_jumpbox" {
  type              = "ingress"
  description       = "Allow SSH from Teleport"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${module.teleport.private_ip_addr}/32"]
  security_group_id = aws_security_group.splunk_server_sg.id
}

resource "aws_security_group_rule" "splunk_allow_http" {
  type        = "ingress"
  description = "Allow HTTP to NGINX"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    #var.publicCIDRblock,
    #var.managementCIDRblock,
    #"0.0.0.0/0"
  ]
  security_group_id = aws_security_group.splunk_server_sg.id
}

resource "aws_security_group_rule" "splunk_allow_https" {
  type        = "ingress"
  description = "Allow HTTPs to NGINX"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    #var.publicCIDRblock,
    #var.managementCIDRblock,
    #"0.0.0.0/0"
  ]
  security_group_id = aws_security_group.splunk_server_sg.id
}

resource "aws_security_group_rule" "splunk_allow_rest_api" {
  type        = "ingress"
  description = "Allow access to Splunk REST API"
  from_port   = 8089
  to_port     = 8089
  protocol    = "tcp"
  cidr_blocks = [
    "${module.teleport.private_ip_addr}/32",
    #var.publicCIDRblock,
    #var.managementCIDRblock,
    #"0.0.0.0/0"
  ]
  security_group_id = aws_security_group.splunk_server_sg.id
}

resource "aws_security_group_rule" "splunk_allow_prometheus" {
  type              = "ingress"
  description       = "Allow prometheus to pull metrics from node exporter"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.metrics.private_ip}/32"]
  security_group_id = aws_security_group.splunk_server_sg.id
}


resource "aws_security_group_rule" "splunk_allow_inbound" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.splunk_server_sg.id
}


resource "aws_instance" "splunk_server" {
  ami                     = var.ubunut-ami
  instance_type           = var.logging_ec2_size
  subnet_id               = aws_subnet.logging.id
  vpc_security_group_ids  = [aws_security_group.splunk_server_sg.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  private_ip              = var.logging_subnet_map["splunk"]
  disable_api_termination = true

  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_splunk_server"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_eip" "splunk_server_eip" {
  instance = aws_instance.splunk_server.id
  vpc      = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_splunk_server_eip"
    Project = var.PROJECT_PREFIX
  }
}


############################################ Logging/SecurityOnion Server ############################################
resource "aws_security_group" "securityonion_server_sg2" {
  vpc_id      = module.vpc.vpc_id
  description = "SecurityOnion security group"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_securityonion_server_sg2"
    Project = var.PROJECT_PREFIX
  }

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from jumphost/teleport"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${module.teleport.private_ip_addr}/32"]
  }

  # Allow SSH from jumpbox
  ingress {
    description = "Allow SSH from jumphost/teleport"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${module.teleport.private_ip_addr}/32"]
  }

  # HTTP port for Web UI
  ingress {
    description = "Allow HTTP from jumphost/teleport"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
    ]
  }

  # HTTPS port for Web UI
  ingress {
    description = "Allow HTTPS from jumphost/teleport"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
    ]
  }

  ingress {
    description = "Allow Prometheus"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.metrics.private_ip}/32"]
  }

  ingress {
    description = "Allow Elastic tcp/9200 from Cribl"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [
      "${module.teleport.private_ip_addr}/32",
      "${var.logging_subnet_map["cribl"]}/32",
    ]
  }

  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description = "Allow Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################ Create Security Onion EC2 instance ############################################
resource "aws_network_interface" "seconion_mgmt_nic" {
  subnet_id       = aws_subnet.logging.id
  private_ips     = [var.logging_subnet_map["securityonion"]]
  security_groups = [aws_security_group.securityonion_server_sg2.id]

  tags = {
    Name    = "${var.PROJECT_PREFIX}_SECURITYONION_MGMT_NIC"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_network_interface" "seconion_tap_interface" {
  subnet_id       = aws_subnet.logging.id
  security_groups = [aws_security_group.seconion_traffic_mirror_sg.id]
  private_ips     = [var.logging_subnet_map["securityonion_bind"]]

  tags = {
    Name    = "${var.PROJECT_PREFIX}_SECONION_SERVER_TAP_INTERFACE"
    Project = var.PROJECT_PREFIX
  }

  # WITHOUT this statement the seconion EC2 will be DESTROYED
  # AND RE-CREATED
  attachment {
    instance     = aws_instance.securityonion_server.id
    device_index = 1
  }
}

# AWS has a limit of 10 mirror sources per interface.
# This interface is created to handle anything greater than 10
# https://docs.aws.amazon.com/vpc/latest/mirroring/traffic-mirroring-limits.html
resource "aws_network_interface" "seconion_tap_interface_overflow" {
  subnet_id       = aws_subnet.logging.id
  security_groups = [aws_security_group.seconion_traffic_mirror_sg.id]
  private_ips     = [var.logging_subnet_map["securityonion_bind_overflow"]]

  tags = {
    Name    = "${var.PROJECT_PREFIX}_SECONION_SERVER_TAP_INTERFACE_OVERFLOW"
    Project = var.PROJECT_PREFIX
  }

  # WITHOUT this statement the seconion EC2 will be DESTROYED
  # AND RE-CREATED
  attachment {
    instance     = aws_instance.securityonion_server.id
    device_index = 2
  }
}

resource "aws_instance" "securityonion_server" {
  ami = var.ubuntu-so-ami
  # instance_type = var.logging_ec2_size
  # Docs prod recommendation - https://docs.securityonion.net/en/2.3/cloud-ami.html
  instance_type = "t3.xlarge"
  # no subnet_id/private_ip/vpc_security_group_ids if network_interface is set explicitely
  # subnet_id               = aws_subnet.logging.id
  # private_ip              = var.logging_subnet_map["securityonion"]
  # vpc_security_group_ids  = [aws_security_group.securityonion_server_sg2.id]
  key_name                = "${var.PROJECT_PREFIX}-ssh-key"
  disable_api_termination = true

  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint          = "enabled"
    http_tokens            = "required"
  }

  network_interface {
    network_interface_id = aws_network_interface.seconion_mgmt_nic.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 150
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  ################## DO NOT TOUCH ##################
  ############# IGNORE instance type ###############
  lifecycle {
    ignore_changes = [
      instance_type,
      cpu_core_count,
      ebs_optimized,
    ]
  }
  ############# IGNORE instance type ###############
  ################## DO NOT TOUCH ##################

  tags = {
    Name    = "${var.PROJECT_PREFIX}_securityonion_server"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_eip" "securityonion_server_eip" {
  network_interface         = aws_network_interface.seconion_mgmt_nic.id
  associate_with_private_ip = var.logging_subnet_map["securityonion"]
  vpc                       = true
  tags = {
    Name    = "${var.PROJECT_PREFIX}_securityonion_server_eip"
    Project = var.PROJECT_PREFIX
  }
}

############################################ Create SecOnion network tap ############################################
resource "aws_security_group" "seconion_traffic_mirror_sg" {
  name   = "AWS Traffic Mirroring"
  vpc_id = module.vpc.vpc_id

  # Allow all inbound
  ingress {
    description      = "Allow ALL inbound traffic on network TAP"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow all outbound
  egress {
    description      = "Allow ALL outbound traffic on network TAP"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_SECONION_TRAFFIC_MIRROR_SG"
    Project = var.PROJECT_PREFIX
  }
}


resource "aws_ec2_traffic_mirror_target" "seconion_traffic_mirror_target" {
  description          = "${var.PROJECT_PREFIX}_seconion ENI target"
  network_interface_id = aws_network_interface.seconion_tap_interface.id

  tags = {
    Name    = "${var.PROJECT_PREFIX}_seconion_traffic_mirror_target"
    Project = var.PROJECT_PREFIX
  }

}

resource "aws_ec2_traffic_mirror_target" "seconion_overflow_traffic_mirror_target" {
  description          = "${var.PROJECT_PREFIX}_seconion_overflow ENI target"
  network_interface_id = aws_network_interface.seconion_tap_interface_overflow.id

  tags = {
    Name    = "${var.PROJECT_PREFIX}_seconion_overflow)traffic_mirror_target"
    Project = var.PROJECT_PREFIX
  }

}

resource "aws_ec2_traffic_mirror_filter" "seconion_traffic_mirror_filter" {
  description = "${var.PROJECT_PREFIX}_seconion traffic mirror filter - Allow All"
  tags = {
    Name    = "${var.PROJECT_PREFIX}_seconion_traffic_mirror_filter"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_ec2_traffic_mirror_filter_rule" "seconion_traffic_mirror_ipv4_filter_rule_ingress" {
  description              = "${var.PROJECT_PREFIX}_seconion_traffic_mirror_ipv4_filter_rule_ingress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 100
  rule_action              = "accept"
  traffic_direction        = "ingress"

}

resource "aws_ec2_traffic_mirror_filter_rule" "seconion_traffic_mirror_ipv6_filter_rule_ingress" {
  description              = "${var.PROJECT_PREFIX}_seconion_traffic_mirror_ipv6_filter_rule_ingress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  destination_cidr_block   = "::/0"
  source_cidr_block        = "::/0"
  rule_number              = 101
  rule_action              = "accept"
  traffic_direction        = "ingress"

}

resource "aws_ec2_traffic_mirror_filter_rule" "seconion_traffic_mirror_ipv4_filter_rule_egress" {
  description              = "${var.PROJECT_PREFIX}_seconion_traffic_mirror_ipv4_filter_rule_egress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 200
  rule_action              = "accept"
  traffic_direction        = "egress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "seconion_traffic_mirror_ipv6_filter_rule_egress" {
  description              = "${var.PROJECT_PREFIX}_seconion_traffic_mirror_ipv6_filter_rule_egress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  destination_cidr_block   = "::/0"
  source_cidr_block        = "::/0"
  rule_number              = 201
  rule_action              = "accept"
  traffic_direction        = "egress"
}

########################################### Create network traffic mirror sessions  - DMZ/prod ###########################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances
data "aws_instances" "dmz_subnet_instances" {
  filter {
    name   = "subnet-id"
    values = [aws_subnet.prod.id]
  }
  instance_state_names = ["running", "stopped"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance#private_ip
data "aws_instance" "dmz_subnet_instance" {
  for_each    = toset(data.aws_instances.dmz_subnet_instances.ids)
  instance_id = each.key
}

# Note: security onion server instance must be running to create below
#	else you will get InvalidTrafficMirrorTarget error
resource "aws_ec2_traffic_mirror_session" "dmz_subnet_tap_traffic_mirror_sessions" {
  for_each = data.aws_instance.dmz_subnet_instance

  description              = "${each.value.tags["Name"]} traffic mirror session"
  network_interface_id     = each.value.network_interface_id
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.seconion_traffic_mirror_target.id
  session_number           = 1
  tags = {
    Name    = "${each.value.tags["Name"]}_traffic_mirror_session"
    Project = var.PROJECT_PREFIX
  }
}

########################################### Create network traffic mirror sessions - CORP ###########################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances
data "aws_instances" "corp_subnet_instances" {
  filter {
    name   = "subnet-id"
    values = [aws_subnet.corp.id]
  }
  instance_state_names = ["running", "stopped"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance#private_ip
data "aws_instance" "corp_subnet_instance" {
  for_each    = toset(data.aws_instances.corp_subnet_instances.ids)
  instance_id = each.key
}

# Note: security onion server instance must be running to create below
#	else you will get InvalidTrafficMirrorTarget error
resource "aws_ec2_traffic_mirror_session" "corp_subnet_tap_traffic_mirror_sessions" {
  for_each = data.aws_instance.corp_subnet_instance

  description              = "${each.value.tags["Name"]} traffic mirror session"
  network_interface_id     = each.value.network_interface_id
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.seconion_traffic_mirror_target.id
  session_number           = 1
  tags = {
    Name    = "${each.value.tags["Name"]}_traffic_mirror_session"
    Project = var.PROJECT_PREFIX
  }
}

########################################### Create network traffic mirror sessions - IoT ###########################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances
data "aws_instances" "iot_plcs_subnet_instances" {
  filter {
    name   = "subnet-id"
    values = [aws_subnet.iot.id]
  }

  filter {
    name   = "tag:IOTtype"
    values = ["plc"]
  }

  instance_state_names = ["running", "stopped"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance#private_ip
data "aws_instance" "iot_plcs_subnet_instance" {
  for_each    = toset(data.aws_instances.iot_plcs_subnet_instances.ids)
  instance_id = each.key
}

# Note: security onion server instance must be running to create below
#	else you will get InvalidTrafficMirrorTarget error
resource "aws_ec2_traffic_mirror_session" "iot_plcs_subnet_tap_traffic_mirror_sessions" {
  for_each = data.aws_instance.iot_plcs_subnet_instance

  description              = "${each.value.tags["Name"]} traffic mirror session"
  network_interface_id     = each.value.network_interface_id
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.seconion_overflow_traffic_mirror_target.id
  session_number           = 1
  tags = {
    Name    = "${each.value.tags["Name"]}_traffic_mirror_session"
    Project = var.PROJECT_PREFIX
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances
data "aws_instances" "iot_hmis_subnet_instances" {
  filter {
    name   = "subnet-id"
    values = [aws_subnet.iot.id]
  }

  filter {
    name   = "tag:IOTtype"
    values = ["hmi"]
  }

  instance_state_names = ["running", "stopped"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance#private_ip
data "aws_instance" "iot_hmis_subnet_instance" {
  for_each    = toset(data.aws_instances.iot_hmis_subnet_instances.ids)
  instance_id = each.key
}

# Note: security onion server instance must be running to create below
#	else you will get InvalidTrafficMirrorTarget error
resource "aws_ec2_traffic_mirror_session" "iot_hmis_subnet_tap_traffic_mirror_sessions" {
  for_each = data.aws_instance.iot_hmis_subnet_instance

  description              = "${each.value.tags["Name"]} traffic mirror session"
  network_interface_id     = each.value.network_interface_id
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.seconion_traffic_mirror_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.seconion_traffic_mirror_target.id
  session_number           = 1
  tags = {
    Name    = "${each.value.tags["Name"]}_traffic_mirror_session"
    Project = var.PROJECT_PREFIX
  }
}
