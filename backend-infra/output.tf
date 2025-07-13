# outputs.tf
output "smtp_credentials" {
  value = {
    username = aws_iam_access_key.smtp_user.id
    password = aws_iam_access_key.smtp_user.ses_smtp_password_v4
  }
  sensitive = true
}

output "verified_emails" {
  value = {
    sender    = aws_ses_email_identity.sender.email
    recipient = aws_ses_email_identity.recipient.email
  }
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.lambda1_api.api_endpoint
}

