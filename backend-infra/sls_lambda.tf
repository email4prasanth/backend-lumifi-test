# IAM permissions for API Gateway to invoke each Lambda
resource "aws_lambda_permission" "apigw" {
  for_each = local.lambda_functions

#   statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  statement_id  = "AllowAPIGatewayInvoke-${terraform.workspace}-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = "serverless-express-app-${terraform.workspace}-${each.value}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}