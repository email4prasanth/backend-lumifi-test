module "lambda1" {
  source = "../services/lambda-1"

  # Pass required variables
  subnet_ids                = aws_subnet.lumifi_subnets[*].id
  lambda_sg_id              = aws_security_group.lambda_sg.id
  lambda_role_arn           = aws_iam_role.lambda_role.arn
  backend_bucket            = aws_s3_bucket.backend.bucket
  api_gateway_id            = aws_apigatewayv2_api.lambda1_api.id
  api_gateway_execution_arn = aws_apigatewayv2_api.lambda1_api.execution_arn
}