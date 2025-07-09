# services/lambda-1/variables.tf
variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "lambda_sg_id" {
  description = "Security group ID for Lambda"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "backend_bucket" {
  description = "S3 bucket name for backend storage"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID for Lambda integration"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permission"
  type        = string
}