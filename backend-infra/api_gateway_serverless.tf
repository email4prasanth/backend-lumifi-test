
# # CloudWatch Log Group for Serverless API Gateway
# resource "aws_cloudwatch_log_group" "serverless_api_logs" {
#   name              = "/aws/api-gw/${aws_apigatewayv2_api.serverless_api.name}"
#   retention_in_days = 14
#   tags              = local.tags
# }


# # API Gateway for Serverless Service
# resource "aws_apigatewayv2_api" "serverless_api" {
#   name          = "${local.project_name.name}-${terraform.workspace}-serverless-api"
#   protocol_type = "HTTP"
#   tags          = local.tags
# }

# resource "aws_apigatewayv2_stage" "serverless_stage" {
#   api_id      = aws_apigatewayv2_api.serverless_api.id
#   name        = "$default"
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.serverless_api_logs.arn
#     format = jsonencode({
#       requestId      = "$context.requestId"
#       ip             = "$context.identity.sourceIp"
#       requestTime    = "$context.requestTime"
#       httpMethod     = "$context.httpMethod"
#       routeKey       = "$context.routeKey"
#       status         = "$context.status"
#       responseLength = "$context.responseLength"
#     })
#   }
#   tags = local.tags
# }

# # API Gateway Integration
# resource "aws_apigatewayv2_integration" "serverless_integration" {
#   api_id = aws_apigatewayv2_api.serverless_api.id
#   # integration_type = "HTTP_PROXY"
#   integration_type = "AWS_PROXY"
#   integration_uri  = data.aws_lambda_function.serverless_lambda.invoke_arn # Point to your serverless Lambda
#   # integration_method     = "ANY"
#   payload_format_version = "1.0"
#   # payload_format_version = "2.0"
# }

# # API Gateway Routes
# resource "aws_apigatewayv2_route" "api_v1_route" {
#   api_id    = aws_apigatewayv2_api.serverless_api.id
#   route_key = "ANY /${local.api_root_path}/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.serverless_integration.id}"
# }

# resource "aws_apigatewayv2_route" "root_route" {
#   api_id    = aws_apigatewayv2_api.serverless_api.id
#   route_key = "ANY /{proxy+}"
#   # route_key = "$default"
#   target = "integrations/${aws_apigatewayv2_integration.serverless_integration.id}"
# }

# resource "aws_apigatewayv2_route" "catchall_route" {
#   api_id    = aws_apigatewayv2_api.serverless_api.id
#   route_key = "$default"
#   target    = "integrations/${aws_apigatewayv2_integration.serverless_integration.id}"
# }
