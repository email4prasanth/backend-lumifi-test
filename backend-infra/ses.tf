# ses.tf
resource "aws_ses_email_identity" "sender" {
  email = local.sender_email
}

resource "aws_ses_email_identity" "recipient" {
  email = local.receiver_email
}

resource "aws_ses_configuration_set" "sandbox" {
  name = "${local.project_name.name}-${terraform.workspace}-ses-sandbox-config"
}

resource "aws_iam_user" "smtp_user" {
  name = "${local.project_name.name}-${terraform.workspace}-ses-smtp-user"
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

resource "aws_iam_user_policy" "smtp_send" {
  name = "${local.project_name.name}-${terraform.workspace}-ses-send-policy"
  user = aws_iam_user.smtp_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ses:SendRawEmail"
      Resource = "*"
    }]
  })
}