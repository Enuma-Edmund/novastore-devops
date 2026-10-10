module "naming" {
  source = "../../modules/naming"

  project_name = "novastore"
  environment  = var.environment
}
