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

resource "aws_iam_role" "security_agent" {
  name = "${var.name_prefix}-security-agent-role"

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
  role       = aws_iam_role.security_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "security_agent" {
  name = "${var.name_prefix}-security-agent-profile"
  role = aws_iam_role.security_agent.name
}

resource "aws_security_group" "security_agent" {
  name        = "${var.name_prefix}-security-agent-sg"
  description = "Security scanner Jenkins agent"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-security-agent-sg"
  }
}

resource "aws_instance" "security_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c7i-flex.large"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.security_agent.id]

  iam_instance_profile = aws_iam_instance_profile.security_agent.name

  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 20
  }

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "${var.name_prefix}-security-agent"
  }
}
