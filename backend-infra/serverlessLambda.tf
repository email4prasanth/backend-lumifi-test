data "aws_lambda_function" "serverless_lambda" {
  function_name = "${terraform.workspace}-serverless-lambda" # Match your serverless deploy name
}

resource "aws_lambda_permission" "serverless_apigw" {
  statement_id  = "AllowServerlessAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.serverless_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.serverless_api.execution_arn}/*/*"
}
