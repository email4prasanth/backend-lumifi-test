# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = aws_subnet.lumifi_subnets[*].id
}