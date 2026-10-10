output "ec2_app_role_name" {
  description = "Name of the EC2 application IAM role"
  value       = aws_iam_role.ec2_app.name
}

output "ec2_app_role_arn" {
  description = "ARN of the EC2 application IAM role"
  value       = aws_iam_role.ec2_app.arn
}

output "ec2_app_instance_profile_name" {
  description = "Name of the EC2 application instance profile"
  value       = aws_iam_instance_profile.ec2_app.name
}
