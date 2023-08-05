###################################################### magnumtempusfinancial.com ######################################################
# We used `data` resource because the zone already
# exists from last year. This just imports it here
# to be used by other resources.
data "aws_route53_zone" "project_route53_zone" {
  name         = var.project_base_domain
  private_zone = false
}

resource "aws_route53_record" "securityonion" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.project_route53_zone.zone_id
  name            = "securityonion.${var.project_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.securityonion_server_eip.public_ip]
}


resource "aws_route53_record" "splunk" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.project_route53_zone.zone_id
  name            = "splunk.${var.project_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.splunk_server_eip.public_ip]
}


resource "aws_route53_record" "cribl" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.project_route53_zone.zone_id
  name            = "cribl.${var.project_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.cribl_server_eip.public_ip]
}

resource "aws_route53_record" "velociraptor" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.project_route53_zone.zone_id
  name            = "velociraptor.${var.project_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.velociraptor_server_eip.public_ip]
}

resource "aws_route53_record" "jupyterhub" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.project_route53_zone.zone_id
  name            = "jupyterhub.${var.project_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.jupyter_server_eip.public_ip]
}

resource "aws_route53_record" "graylog" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.project_route53_zone.zone_id
  name            = "graylog.${var.project_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.graylog_server_eip.public_ip]
}

###################################################### blueteamvillage.com ######################################################
resource "aws_route53_record" "graylog_btv" {
  allow_overwrite = true
  zone_id         = var.btv_route53_zone_id
  name            = "graylog.${var.btv_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.graylog_server_eip.public_ip]
}

resource "aws_route53_record" "jupyterhub_btv" {
  allow_overwrite = true
  zone_id         = var.btv_route53_zone_id
  name            = "jupyterhub.${var.btv_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.jupyter_server_eip.public_ip]
}

resource "aws_route53_record" "splunk_btv" {
  allow_overwrite = true
  zone_id         = var.btv_route53_zone_id
  name            = "splunk.${var.btv_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.splunk_server_eip.public_ip]
}

resource "aws_route53_record" "securityonion_btv" {
  allow_overwrite = true
  zone_id         = var.btv_route53_zone_id
  name            = "securityonion.${var.btv_base_domain}"
  type            = "A"
  ttl             = 300
  records         = [aws_eip.securityonion_server_eip.public_ip]
}
