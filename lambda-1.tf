# Lambda Function: Data Processor
resource "aws_lambda_function" "data_processor" {
  function_name = "${local.project_name.name}-${terraform.workspace}-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "lambda-1.zip"

  vpc_config {
    subnet_ids         = aws_subnet.lumifi_subnets[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      S3_BUCKET    = aws_s3_bucket.backend.bucket
      ENVIRONMENT  = terraform.workspace
      SERVICE_NAME = "data-processor"
    }
  }

  tags = local.tags
}

# API Gateway v2 (HTTP API)
resource "aws_apigatewayv2_api" "lambda1_api" {
  name          = "${local.project_name.name}-${terraform.workspace}-processor-api"
  protocol_type = "HTTP"
}

# API Gateway Stage
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

# API Gateway Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda1_integration" {
  api_id           = aws_apigatewayv2_api.lambda1_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.data_processor.invoke_arn
}

# API Gateway Routes
resource "aws_apigatewayv2_route" "lambda1_route" {
  api_id    = aws_apigatewayv2_api.lambda1_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
}
resource "aws_apigatewayv2_route" "lambda1_root" {
  api_id    = aws_apigatewayv2_api.lambda1_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "lambda1_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda1_api.execution_arn}/*/*"
}

# CloudWatch Log Groups for Lambda & API Gateway
resource "aws_cloudwatch_log_group" "lambda1_logs" {
  name              = "/aws/lambda/${aws_lambda_function.data_processor.function_name}"
  retention_in_days = 14
  tags              = local.tags
}
resource "aws_cloudwatch_log_group" "lambda1_api_logs" {
  name              = "/aws/api-gw/${aws_apigatewayv2_api.lambda1_api.name}"
  retention_in_days = 14
  tags              = local.tags
}

