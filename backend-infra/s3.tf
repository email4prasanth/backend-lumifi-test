# S3 Bucket - Backend Data
resource "aws_s3_bucket" "backend" {
  bucket = "${local.project_name.name}-${terraform.workspace}-backend-test"
  tags   = local.tags
}
resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Disabled"
  }
}

# S3 Bucket - Logs Storage
resource "aws_s3_bucket" "logs" {
  bucket = "${local.project_name.name}-${terraform.workspace}-logs-test"
  tags   = local.tags
}
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id
  # block_public_acls       = false
  # block_public_policy     = false
  # ignore_public_acls      = false
  # restrict_public_buckets = false
  block_public_acls       = terraform.workspace == "prod" ? true : false
  block_public_policy     = terraform.workspace == "prod" ? true : false
  ignore_public_acls      = terraform.workspace == "prod" ? true : false
  restrict_public_buckets = terraform.workspace == "prod" ? true : false

}