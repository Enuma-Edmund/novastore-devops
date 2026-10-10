module "naming" {
  source = "../../modules/naming"

  project_name = "novastore"
  environment  = var.environment
}
module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = module.naming.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}
module "s3" {
  source = "../../modules/s3"

  name_prefix = module.naming.name_prefix
}

module "iam" {
  source = "../../modules/iam"

  name_prefix    = module.naming.name_prefix
  environment    = var.environment
  app_bucket_arn = module.s3.bucket_arn
}
module "ecr" {
  source = "../../modules/ecr"

  name_prefix = module.naming.name_prefix
}
module "jenkins" {
  source = "../../modules/jenkins"

  name_prefix          = module.naming.name_prefix
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  allowed_ssh_cidr     = var.admin_cidr
  allowed_jenkins_cidr = var.admin_cidr
}
module "ecs" {
  source = "../../modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  container_image = "${module.ecr.repository_url}:215b16fb43669bfb6e516f44d459b0744464d03f"

  container_port = 8080

  task_cpu    = 256
  task_memory = 512

  desired_count = 2
  min_capacity  = 2
  max_capacity  = 4
}
module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.small"]

  node_desired_size = 2
  node_min_size     = 2
  node_max_size     = 4
}

module "sonarqube" {
  source = "../../modules/sonarqube"

  name_prefix               = module.naming.name_prefix
  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.public_subnet_ids[0]
  jenkins_security_group_id = module.jenkins.security_group_id
}
module "security_agent" {
  source = "../../modules/security-agent"

  name_prefix = module.naming.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]
}
