variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC where ECS resources will run"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the Application Load Balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets for ECS Fargate tasks"
  type        = list(string)
}

variable "container_image" {
  description = "ECR image URI used by the ECS task"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units allocated to the Fargate task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory allocated to the Fargate task in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}
