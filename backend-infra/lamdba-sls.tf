# Add this to lambda-test.tf
resource "aws_lambda_function" "serverless_proxy" {
  filename      = "lambda/serverless_proxy.zip"
  function_name = "${local.project_name.name}-${terraform.workspace}-serverless-proxy"
  role          = aws_iam_role.lambda_role.arn
  handler       = "serverless_proxy.lambda_handler"
  runtime       = "python3.12"
  source_code_hash = filebase64sha256("lambda/serverless_proxy.zip")

  tags = merge(local.tags, local.project_name)
}

data "archive_file" "serverless_proxy_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/serverless_proxy.py"
  output_path = "${path.module}/lambda/serverless_proxy.zip"
}