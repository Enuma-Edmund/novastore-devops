provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "novastore"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

