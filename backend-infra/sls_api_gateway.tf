# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "serverless-express-app"
  protocol_type = "HTTP"
  tags          = local.tags
}

# Default stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      routeKey         = "$context.routeKey"
      status           = "$context.status"
      integrationError = "$context.integrationErrorMessage"
    })
  }
}


# Create integrations
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.lambda_functions

  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = "arn:aws:lambda:${local.aws_region}:${data.aws_caller_identity.current.account_id}:function:serverless-express-app-${terraform.workspace}-${each.value}"
}

# Route for /api/v1/* to appropriate Lambda integration
resource "aws_apigatewayv2_route" "api_v1_routes" {
  for_each = {
    # Map route keys to Lambda functions
    "ANY /api/v1/security/{proxy+}" = "security"
    "ANY /api/v1/state/{proxy+}"    = "state"
    # "ANY /api/v1/hello"             = "api"
    "GET /api/v1/hello" = "api"
    "ANY /api/v1/patient/{proxy+}"  = "patient"
    "ANY /api/v1/user/{proxy+}"     = "user"
    "ANY /api/v1/practice/{proxy+}" = "practice"
    "ANY /api/v1/auth/{proxy+}"     = "auth"
  }

  api_id    = aws_apigatewayv2_api.main.id
  route_key = each.key
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.value].id}"
}

# Output API Gateway URL
output "api_url" {
  value = "${aws_apigatewayv2_api.main.api_endpoint}/api/v1"
}