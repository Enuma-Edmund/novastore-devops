variable "name_prefix" {
  description = "Standard naming prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the Jenkins server will run"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for the Jenkins server"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into Jenkins"
  type        = string
}

variable "allowed_jenkins_cidr" {
  description = "CIDR allowed to access the Jenkins web interface"
  type        = string
}

