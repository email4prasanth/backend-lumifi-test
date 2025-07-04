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


# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "lambda1_api_logs" {
  name              = "/aws/api-gw/${aws_apigatewayv2_api.lambda1_api.name}"
  retention_in_days = 14
  tags              = local.tags
}

# Keep only ONE copy of these resources:
resource "aws_apigatewayv2_api" "lambda1_api" {
  name          = "${local.project_name.name}-${terraform.workspace}-processor-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda1_stage" {
  api_id      = aws_apigatewayv2_api.lambda1_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda1_api_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }
}
