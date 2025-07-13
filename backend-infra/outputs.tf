output "api_url" {
  value = "${aws_apigatewayv2_api.lambda1_api.api_endpoint}/test"
}