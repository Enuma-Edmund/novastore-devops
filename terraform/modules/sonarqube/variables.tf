variable "name_prefix" {
  description = "Standard naming prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC where SonarQube will run"
  type        = string
}

variable "subnet_id" {
  description = "Subnet for the SonarQube EC2 instance"
  type        = string
}

variable "jenkins_security_group_id" {
  description = "Jenkins security group allowed to access SonarQube"
  type        = string
}
