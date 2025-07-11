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

resource "aws_apigatewayv2_route" "lambda1_test" {
  api_id    = aws_apigatewayv2_api.lambda1_api.id
  route_key = "ANY /test"
  target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
}

# resource "aws_apigatewayv2_route" "lambda1_test_slash" {
#   api_id    = aws_apigatewayv2_api.lambda1_api.id
#   route_key = "ANY /test/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
# }

resource "aws_apigatewayv2_integration" "lambda1_integration" {
  api_id           = aws_apigatewayv2_api.lambda1_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = module.lambda1.lambda_function_invoke_arn
}

resource "aws_apigatewayv2_route" "lambda1_root" {
  api_id    = aws_apigatewayv2_api.lambda1_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
}

