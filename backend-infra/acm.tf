# # API Gateway Certificate
# resource "aws_acm_certificate" "api_cert" {
#   domain_name       = "api.aitechlearn.xyz"
#   validation_method = "DNS"
# }

# # DNS Validation for API Certificate
# resource "aws_route53_record" "api_cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.domain.zone_id
# }

# # Certificate Validation for API
# resource "aws_acm_certificate_validation" "api_cert" {
#   certificate_arn         = aws_acm_certificate.api_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
# }