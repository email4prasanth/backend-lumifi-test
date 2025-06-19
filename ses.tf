# SES Domain Identity
resource "aws_ses_domain_identity" "domain" {
  domain = "aitechlearn.xyz"
}

# SES DKIM Verification
resource "aws_ses_domain_dkim" "domain_dkim" {
  domain = aws_ses_domain_identity.domain.domain
}

# Route53 DKIM Records
resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${element(aws_ses_domain_dkim.domain_dkim.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SES Configuration Set
resource "aws_ses_configuration_set" "config_set" {
  name = "${local.project_name.name}-${terraform.workspace}-config-set"
}

# SNS Topic for SES Events
resource "aws_sns_topic" "ses_events" {
  name = "${local.project_name.name}-${terraform.workspace}-ses-events"
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "ses_events" {
  arn = aws_sns_topic.ses_events.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowSESPublish"
      Effect = "Allow"
      Principal = {
        Service = "ses.amazonaws.com"
      }
      Action   = "sns:Publish"
      Resource = aws_sns_topic.ses_events.arn
    }]
  })
}

# SNS Subscription
resource "aws_sns_topic_subscription" "ses_events" {
  topic_arn = aws_sns_topic.ses_events.arn
  protocol  = "email"
  endpoint  = "admin@aitechlearn.xyz" # Replace with actual email
}