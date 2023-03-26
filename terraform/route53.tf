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
