variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "deploy_public_rds" {
  description = "Whether to deploy public RDS (true for dev, false for prod)"
  type        = bool
  default     = false
}

variable "deploy_private_rds" {
  description = "Whether to deploy private RDS (false for dev, true for prod)"
  type        = bool
  default     = true
}