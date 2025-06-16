# KMS Key
resource "aws_kms_key" "cmk" {
  description             = "Customer managed CMK for ${local.project_name.name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIAMPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowLambdaUsage"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# KMS Alias
resource "aws_kms_alias" "cmk" {
  name          = "alias/${local.project_name.name}-cmk"
  target_key_id = aws_kms_key.cmk.key_id
}