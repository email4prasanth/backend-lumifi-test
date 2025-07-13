# Create a new API Gateway for serverless functions
resource "aws_apigatewayv2_api" "serverless_api" {
  name          = "${local.project_name.name}-${terraform.workspace}-serverless-api"
  protocol_type = "HTTP"
  tags          = merge(local.tags, local.project_name)
}

resource "aws_apigatewayv2_stage" "serverless_api" {
  api_id      = aws_apigatewayv2_api.serverless_api.id
  name        = "$default"
  auto_deploy = true
}

# Create a wildcard integration for /api/v1/*
resource "aws_apigatewayv2_integration" "serverless_root" {
  api_id             = aws_apigatewayv2_api.serverless_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = "arn:aws:apigateway:${local.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${local.aws_region}:${data.aws_caller_identity.current.account_id}:function:serverless-express-app-dev-api/invocations"
}

# Create a catch-all route for /api/v1/*
resource "aws_apigatewayv2_route" "api_v1_proxy" {
  api_id    = aws_apigatewayv2_api.serverless_api.id
  route_key = "ANY /api/v1/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.serverless_root.id}"
}

# Grant API Gateway permission to invoke the Lambda
resource "aws_lambda_permission" "serverless_api_gw" {
  statement_id  = "AllowServerlessAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "serverless-express-app-dev-api"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.serverless_api.execution_arn}/*/*"
}