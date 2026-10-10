variable "name_prefix" {
  description = "Standard naming prefix for IAM resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "app_bucket_arn" {
  description = "ARN of the S3 bucket the EC2 application may read from"
  type        = string
}
