# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "${terraform.workspace}-lumifi-api"
  protocol_type = "HTTP"
  tags          = local.tags
}

# Default stage for API Gateway
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

# Integration for Lambda functions
resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = "arn:aws:lambda:${local.aws_region}:${data.aws_caller_identity.current.account_id}:function:${terraform.workspace}-lumifi-api"
}

# Route for /api/v1/* to Lambda integration
resource "aws_apigatewayv2_route" "api_v1_proxy" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /api/v1/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Output API Gateway URL
output "api_url" {
  value = "${aws_apigatewayv2_api.main.api_endpoint}/api/v1"
}