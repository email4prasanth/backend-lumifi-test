data "archive_file" "lambda_test_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/test_function.py"
  output_path = "${path.module}/lambda/test_function.zip"
}

resource "aws_lambda_function" "test_function" {
  filename         = data.archive_file.lambda_test_zip.output_path
  function_name    = "${local.project_name.name}-${terraform.workspace}-test"
  role             = aws_iam_role.lambda_role.arn
  handler          = "test_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_test_zip.output_base64sha256

  tags = merge(local.tags, local.project_name)
}