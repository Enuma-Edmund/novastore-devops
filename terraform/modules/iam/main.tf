resource "aws_iam_role" "ec2_app" {
  name = "${var.name_prefix}-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ec2-app-role"
    Environment = var.environment
  }
}
resource "aws_iam_policy" "ec2_app_s3_read" {
  name        = "${var.name_prefix}-ec2-app-s3-read"
  description = "Allows the EC2 application to read objects from its application S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${var.app_bucket_arn}/*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_app_s3_read" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = aws_iam_policy.ec2_app_s3_read.arn
}
resource "aws_iam_instance_profile" "ec2_app" {
  name = "${var.name_prefix}-ec2-app-profile"
  role = aws_iam_role.ec2_app.name
}
