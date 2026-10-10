output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "HTTP URL of the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.app.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group used by ECS"
  value       = aws_cloudwatch_log_group.ecs.name
}
