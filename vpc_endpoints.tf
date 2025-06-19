# # VPC Endpoint for Amazon S3 (Gateway Type)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.lumifi-vpc.id
#   service_name      = "com.amazonaws.${local.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_route_table.lumifi-pub-rt.id]
# }
# # VPC Endpoint for AWS Secrets Manager (Interface Type)
# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = aws_vpc.lumifi-vpc.id
#   service_name        = "com.amazonaws.${local.aws_region}.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.lumifi_subnets[*].id   # Attach endpoint to subnets
#   security_group_ids  = [aws_security_group.lambda_sg.id] # Use Lambda SG to allow Secrets Manager traffic
#   private_dns_enabled = true                              # Enable private DNS for internal resolution
# }