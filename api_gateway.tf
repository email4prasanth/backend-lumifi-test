# API Gateway Custom Domain
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.aitechlearn.xyz"
  depends_on  = [aws_acm_certificate_validation.api_cert]

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# API Gateway mapping for Lambda1
resource "aws_apigatewayv2_api_mapping" "lambda1" {
  api_id      = aws_apigatewayv2_api.lambda1_api.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.lambda1_stage.id
}