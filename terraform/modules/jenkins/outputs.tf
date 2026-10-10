output "public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "instance_id" {
  description = "EC2 instance ID of the Jenkins server"
  value       = aws_instance.jenkins.id
}

output "security_group_id" {
  description = "Security group ID of the Jenkins server"
  value       = aws_security_group.jenkins.id
}
