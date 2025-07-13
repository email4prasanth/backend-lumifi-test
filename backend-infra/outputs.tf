output "api_url" {
  value = "${aws_apigatewayv2_api.lambda1_api.api_endpoint}/test"
}

output "serverless_api_url" {
  value = aws_apigatewayv2_api.serverless_api.api_endpoint
}

# Add these outputs
output "api_gateway_id" {
  value = aws_apigatewayv2_api.lambda1_api.id
}

output "api_gateway_execution_arn" {
  value = aws_apigatewayv2_api.lambda1_api.execution_arn
}