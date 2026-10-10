output "name_prefix" {
  description = "Naming prefix for development resources"
  value       = module.naming.name_prefix
}
output "vpc_id" {
  description = "ID of the development VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the development public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the development private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the development NAT Gateway"
  value       = module.vpc.nat_gateway_id
}
output "app_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = module.s3.bucket_id
}

output "app_bucket_arn" {
  description = "ARN of the application S3 bucket"
  value       = module.s3.bucket_arn
}

output "ec2_app_role_name" {
  description = "Name of the EC2 application IAM role"
  value       = module.iam.ec2_app_role_name
}

output "ec2_app_instance_profile_name" {
  description = "Name of the EC2 application instance profile"
  value       = module.iam.ec2_app_instance_profile_name
}
output "ecr_repository_url" {
  description = "URL of the application ECR repository"
  value       = module.ecr.repository_url
}
output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = module.jenkins.public_ip
}

output "jenkins_instance_id" {
  description = "EC2 instance ID of the Jenkins server"
  value       = module.jenkins.instance_id
}
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "ecs_alb_url" {
  description = "Public URL for the ECS application"
  value       = module.ecs.alb_url
}

output "ecs_cloudwatch_log_group" {
  description = "CloudWatch log group for ECS"
  value       = module.ecs.cloudwatch_log_group
}
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "EKS managed node group name"
  value       = module.eks.node_group_name
}
