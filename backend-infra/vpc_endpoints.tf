# # VPC Endpoint for Amazon S3 (Gateway Type)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

#   service_name      = "com.amazonaws.${local.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : try(data.aws_route_tables.public.ids[0], null)
# }
# # VPC Endpoint for AWS Secrets Manager (Interface Type)
# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

#   service_name        = "com.amazonaws.${local.aws_region}.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.public.ids
#   security_group_ids  = [aws_security_group.lambda_sg.id] # Use Lambda SG to allow Secrets Manager traffic
#   private_dns_enabled = true                              # Enable private DNS for internal resolution
# }