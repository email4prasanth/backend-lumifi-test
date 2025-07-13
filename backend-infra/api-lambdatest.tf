resource "aws_apigatewayv2_api" "lambda1_api" {
  name          = "${local.project_name.name}-${terraform.workspace}-api"
  protocol_type = "HTTP"
  tags          = merge(local.tags, local.project_name)
}

resource "aws_apigatewayv2_stage" "lambda1_api" {
  api_id      = aws_apigatewayv2_api.lambda1_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_test" {
  api_id             = aws_apigatewayv2_api.lambda1_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.test_function.invoke_arn
}

resource "aws_apigatewayv2_route" "test" {
  api_id    = aws_apigatewayv2_api.lambda1_api.id
  route_key = "GET /test"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_test.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda1_api.execution_arn}/*/*"
}



