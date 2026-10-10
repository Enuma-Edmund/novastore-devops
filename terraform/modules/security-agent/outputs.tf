output "instance_id" {
  value = aws_instance.security_agent.id
}

output "private_ip" {
  value = aws_instance.security_agent.private_ip
}

output "security_group_id" {
  value = aws_security_group.security_agent.id
}
