

module "aws_vpc" {
  source      = "./modules/aws/vpc"
  project     = local.project
  cidr_block  = "10.0.0.0/16"
  tags        = local.common_tags
}

module "aws_ecs" {
  source      = "./modules/aws/ecs"
  project     = local.project
  vpc_id      = module.aws_vpc.vpc_id          # ← output from vpc, input to ecs
  subnet_ids  = module.aws_vpc.private_subnets # ← same pattern
  image_uri   = var.container_image
  tags        = local.common_tags
}

module "aws_dns" {
  source       = "./modules/aws/dns"
  alb_dns_name = module.aws_ecs.alb_dns_name   # ← output from ecs, input to dns
  gcp_lb_ip    = module.gcp_dns.lb_ip
  active_cloud = var.active_cloud              # ← controls weights
}