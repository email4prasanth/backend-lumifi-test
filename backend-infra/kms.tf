resource "aws_kms_key" "lumifi_cmk" {
  description             = "Lumifi CMK for encrypting RDS and other sensitive data"
  deletion_window_in_days = 30
  enable_key_rotation     = true


  policy = <<POLICY
{
"Version": "2012-10-17",
"Id": "key-default-1",
"Statement": [
{
"Sid": "Enable IAM User Permissions",
"Effect": "Allow",
"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
"Action": "kms:*",
"Resource": "*"
}
]
}
POLICY
}


resource "aws_kms_alias" "lumifi_alias" {
  name          = "alias/${local.project_name.name}-${terraform.workspace}-cmk"
  target_key_id = aws_kms_key.lumifi_cmk.key_id
}

