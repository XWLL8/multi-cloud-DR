
module "vpc" {
  source = "./modules/aws/vpc"

  project_name   = var.project_name
  vpc_cidr_block = "10.0.0.0/16"
}

module "dns" {
  source = "./modules/aws/dns"

  domain_name       = var.domain_name
  route53_zone_name = var.route53_zone_name
}

module "alb" {
  source = "./modules/aws/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.dns.certificate_arn
}

module "ecs" {
  source = "./modules/aws/ecs"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  container_port        = var.container_port
  alb_security_group_id = module.alb.alb_sg
  aws_region            = var.aws_region
  alb_target_group_arn  = module.alb.alb_target_group_arn
}

resource "aws_route53_record" "app" {
  zone_id = module.dns.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
