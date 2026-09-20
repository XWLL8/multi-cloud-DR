



module "vpc" {
  source = "./modules/aws/vpc"

  project_name    = var.project_name
  vpc_cidr_block = "10.0.0.0/16"
}

module "alb" {
  source = "./modules/aws/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}