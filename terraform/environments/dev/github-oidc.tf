# GitHub Actions OIDC Provider
# Allows AWS to recognize identity tokens issued by GitHub Actions.

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}


# GitHub Actions IAM Role
# Allows workflows from the NovaStore repository to assume
# this AWS role using temporary OIDC credentials.

resource "aws_iam_role" "github_actions" {
  name = "novastore-dev-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Enuma-Edmund/novastore-devops:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}


# ECR Permissions for GitHub Actions
# Allows authentication to ECR and image push/pull operations
# only against the NovaStore application repository.

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "novastore-dev-github-actions-ecr"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]

        Resource = module.ecr.repository_arn
      }
    ]
  })
}
