resource "aws_lambda_function" "data_processor" {
  function_name = "${terraform.workspace}-lumifi-processor"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "${path.module}/lambda-1.zip"
  # filename      = "${path.root}/lambda-1.zip"
  # source_code_hash = filebase64sha256("${path.root}/lambda-1.zip") # Add this line

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      S3_BUCKET = var.backend_bucket
      ENVIRONMENT = terraform.workspace
      SERVICE_NAME = "data-processor"
    }
  }

  tags = local.tags
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "lambda1_integration" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.data_processor.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda1_route" {
  api_id    = var.api_gateway_id
  route_key = "ANY /test"
  target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
}

resource "aws_lambda_permission" "lambda1_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda1_logs" {
  name              = "/aws/lambda/${aws_lambda_function.data_processor.function_name}"
  retention_in_days = 14
  tags              = local.tags
}