

# The entire section creates a certificate, public zone, and validates the certificate using DNS method.

# Create the certificate using a wildcard for all the domains created in mbarokah.website
resource "aws_acm_certificate" "mbarokah" {
  domain_name       = "*.mbarokah.website"
  validation_method = "DNS"
}

# calling the hosted zone
data "aws_route53_zone" "mbarokah" {
  name         = "mbarokah.website"
  private_zone = false
}

# selecting validation method
resource "aws_route53_record" "mbarokah" {
  for_each = {
    for dvo in aws_acm_certificate.mbarokah.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.mbarokah.zone_id
}

# validate the certificate through DNS method
resource "aws_acm_certificate_validation" "mbarokah" {
  certificate_arn         = aws_acm_certificate.mbarokah.arn
  validation_record_fqdns = [for record in aws_route53_record.mbarokah : record.fqdn]
}

# create records for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.mbarokah.zone_id
  name    = "tooling.mbarokah.website"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}


# create records for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.mbarokah.zone_id
  name    = "wordpress.mbarokah.website"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}

