variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "novastore"
}

variable "aws_region" {
  description = "AWS region for the development environment"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zones used by the subnets"
  type        = list(string)
}
variable "admin_cidr" {
  description = "CIDR allowed to administer Jenkins"
  type        = string
}
