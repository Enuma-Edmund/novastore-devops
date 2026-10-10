resource "aws_security_group" "sonarqube" {
  name        = "${var.name_prefix}-sonarqube-sg"
  description = "Security group for SonarQube"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SonarQube access from Jenkins only"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [var.jenkins_security_group_id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sonarqube-sg"
  }
}

resource "aws_iam_role" "sonarqube" {
  name = "${var.name_prefix}-sonarqube-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.sonarqube.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "sonarqube" {
  name = "${var.name_prefix}-sonarqube-profile"
  role = aws_iam_role.sonarqube.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c7i-flex.large"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sonarqube.id]

  iam_instance_profile = aws_iam_instance_profile.sonarqube.name

  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name_prefix}-sonarqube"
  }
}
