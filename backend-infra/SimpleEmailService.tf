# SES Domain Identity
resource "aws_ses_domain_identity" "main" {
  domain = "aitechlearn.xyz"
}

# SES Verification Record in Route53
resource "aws_route53_record" "ses_verification" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

# SES Domain Identity Verification
resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id
  depends_on = [aws_route53_record.ses_verification]
}

# Verified Email Address (Replace with your email)
resource "aws_ses_email_identity" "sender" {
  email = "you@example.com"  # Change to your verified email
}