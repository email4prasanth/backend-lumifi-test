# Glacier Vault
resource "aws_glacier_vault" "deep_archive" {
  name = "${local.project_name.name}-${terraform.workspace}-deep-archive"
  access_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowFullAccess",
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      Action   = "glacier:*",
      Resource = "arn:aws:glacier:${local.aws_region}:${data.aws_caller_identity.current.account_id}:vaults/${local.project_name.name}-${terraform.workspace}-deep-archive"
    }]
  })
  tags = local.tags
}

# S3 Glacier Bucket
resource "aws_s3_bucket" "archive" {
  bucket = "${local.project_name.name}-${terraform.workspace}-archive"
  tags   = local.tags
}

# Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id

  rule {
    id = "deep-archive-rule"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "archive" {
  bucket = aws_s3_bucket.archive.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.archive.arn,
        "${aws_s3_bucket.archive.arn}/*"
      ]
    }]
  })
}