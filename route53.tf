# # Route 53 Hosted Zone Lookup
# data "aws_route53_zone" "domain" {
#   name         = "aitechlearn.xyz."
#   private_zone = false
# }

# # API Gateway Custom Domain Alias Record
# resource "aws_route53_record" "api_gateway" {
#   zone_id = data.aws_route53_zone.domain.zone_id
#   name    = "api.aitechlearn.xyz"
#   type    = "A"

#   alias {
#     name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
#     zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
#     evaluate_target_health = false
#   }
# }