data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "alb_controller_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "novastore-dev-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_trust.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "alb_controller" {
  name   = "novastore-dev-alb-controller"
  policy = file("${path.module}/../../policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

output "alb_controller_role_arn" {
  description = "IAM role for the AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}
