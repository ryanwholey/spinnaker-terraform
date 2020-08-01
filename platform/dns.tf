data "aws_route53_zone" "master" {
  name = var.hosted_zone
}

resource "aws_acm_certificate" "eks" {
  domain_name       = "*.${var.hosted_zone}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "eks" {
  certificate_arn = aws_acm_certificate.eks.arn
}

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.master.id

  name    = aws_acm_certificate.eks.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.eks.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.eks.domain_validation_options[0].resource_record_value]

  ttl = 60
}
