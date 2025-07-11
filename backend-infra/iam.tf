# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name = "${local.project_name.name}-${terraform.workspace}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole",
        "logs:*"
      ]
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach AWS Managed Policies to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# # Custom IAM Policy for S3, RDS, Secrets Manager Access
# resource "aws_iam_policy" "lambda_s3_rds_access" {
#   name        = "${local.project_name.name}-${terraform.workspace}-lambda-s3-rds"
#   description = "Access to S3 buckets and RDS"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = ["s3:*", "ec2:*"]
#         Effect = "Allow"
#         Resource = [
#           aws_s3_bucket.backend.arn,
#           "${aws_s3_bucket.backend.arn}/*"
#         ]
#       },
#       {
#         Action   = "secretsmanager:GetSecretValue"
#         Effect   = "Allow"
#         Resource = aws_secretsmanager_secret.rds_credentials.arn
#       },
#       {
#         Action   = "rds-db:connect"
#         Effect   = "Allow"
#         Resource = "arn:aws:rds-db:${local.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres.resource_id}/dbadmin"
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "lambda_s3_rds" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_s3_rds_access.arn
# }

# # Data Source: AWS Caller Identity
# data "aws_caller_identity" "current" {}

# # Custom IAM Policy for API Gateway Logging
# resource "aws_iam_policy" "api_gateway_logging" {
#   name        = "${local.project_name.name}-${terraform.workspace}-api-gw-logging"
#   description = "Permissions for API Gateway to write logs"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action   = ["logs:*"]
#       Effect   = "Allow"
#       Resource = "*"
#     }]
#   })
# }
# resource "aws_iam_role_policy_attachment" "api_gw_logging" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.api_gateway_logging.arn
# }