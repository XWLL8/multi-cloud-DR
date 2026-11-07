
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
  container_port    = var.container_port
  http_port         = var.http_port
  https_port        = var.https_port
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
  create_ecs_service    = var.create_ecs_service
}

resource "aws_route53_record" "app" {
  count = var.azure_dns_mode == "aws_only" ? 1 : 0

  zone_id = module.dns.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

moved {
  from = aws_route53_record.app
  to   = aws_route53_record.app[0]
}

resource "azurerm_resource_group" "dr" {
  name     = "multi-cloud-dr-az"
  location = var.azure_location

  lifecycle {
    precondition {
      condition     = var.azure_dns_mode == "aws_only" || var.enable_azure_container_app
      error_message = "Deploy the Azure Container App before changing Azure DNS mode."
    }

    precondition {
      condition = (
        !var.enable_azure_certificate ||
        (length(trimspace(var.azure_certificate_pfx_path)) > 0 && length(var.azure_certificate_password) > 0)
      )
      error_message = "Set azure_certificate_pfx_path and azure_certificate_password before enabling the Azure certificate."
    }

    precondition {
      condition = (
        !var.enable_azure_certificate ||
        var.enable_azure_container_app
      )
      error_message = "Deploy the Azure Container App before enabling its certificate."
    }

    precondition {
      condition = (
        !var.enable_azure_custom_domain ||
        var.enable_azure_container_app
      )
      error_message = "Deploy the Azure Container App before enabling its custom domain."
    }

    precondition {
      condition = (
        !var.enable_azure_custom_domain ||
        var.enable_azure_certificate
      )
      error_message = "Enable the Azure certificate before binding the custom domain."
    }

    precondition {
      condition     = var.azure_dns_mode != "weighted" || var.enable_azure_custom_domain
      error_message = "Bind the Azure custom domain before enabling weighted DNS routing."
    }
  }
}

resource "azurerm_log_analytics_workspace" "dr" {
  name                = "law-multi-cloud-dr-az"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

locals {
  azure_registry_name = "${substr(replace(lower(var.project_name), "-", ""), 0, 30)}${substr(md5(var.azure_subscription_id), 0, 8)}"
  azure_image         = "${module.azure_container_registry.login_server}/${var.project_name}:${var.azure_image_tag}"
}

data "azurerm_client_config" "current" {}

module "azure_container_registry" {
  source = "./modules/azure/container_registry"

  registry_name       = local.azure_registry_name
  identity_name       = "id-multi-cloud-dr-az"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = module.azure_container_registry.registry_id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.current.object_id
}

module "azure_container_app" {
  count  = var.enable_azure_container_app ? 1 : 0
  source = "./modules/azure/container_app"

  environment_name           = "cae-multi-cloud-dr"
  project_name               = var.project_name
  location                   = var.azure_location
  resource_group_name        = azurerm_resource_group.dr.name
  container_port             = var.container_port
  container_image            = local.azure_image
  registry_server            = module.azure_container_registry.login_server
  registry_identity_id       = module.azure_container_registry.identity_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.dr.id

  depends_on = [module.azure_container_registry]
}

resource "aws_route53_record" "azure_domain_verification" {
  count = var.enable_azure_container_app ? 1 : 0

  zone_id = module.dns.zone_id
  name    = "asuid.${var.domain_name}"
  type    = "TXT"
  ttl     = 300
  records = [module.azure_container_app[0].custom_domain_verification_id]
}

resource "aws_route53_record" "app_azure_validation" {
  count = var.azure_dns_mode == "azure_validation" ? 1 : 0

  zone_id = module.dns.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 60
  records = [module.azure_container_app[0].app_fqdn]

  depends_on = [aws_route53_record.app]
}

resource "azurerm_container_app_environment_certificate" "app" {
  count = var.enable_azure_certificate ? 1 : 0

  name                         = "multi-cloud-dr-app-tls"
  container_app_environment_id = module.azure_container_app[0].environment_id
  certificate_blob_base64      = sensitive(filebase64(var.azure_certificate_pfx_path))
  certificate_password         = var.azure_certificate_password
}

resource "azurerm_container_app_custom_domain" "app" {
  count = var.enable_azure_custom_domain ? 1 : 0

  name                                     = var.domain_name
  container_app_id                         = module.azure_container_app[0].app_id
  container_app_environment_certificate_id = azurerm_container_app_environment_certificate.app[0].id
  certificate_binding_type                 = "SniEnabled"

  depends_on = [
    aws_route53_record.azure_domain_verification
  ]
}

resource "aws_route53_health_check" "aws" {
  count = var.azure_dns_mode == "weighted" ? 1 : 0

  fqdn              = module.alb.alb_dns_name
  port              = var.https_port
  type              = "HTTPS"
  resource_path     = "/health"
  request_interval  = 30
  failure_threshold = 3
  enable_sni        = true
}

resource "aws_route53_health_check" "azure" {
  count = var.azure_dns_mode == "weighted" ? 1 : 0

  fqdn              = module.azure_container_app[0].app_fqdn
  port              = var.https_port
  type              = "HTTPS"
  resource_path     = "/health"
  request_interval  = 30
  failure_threshold = 3
  enable_sni        = true
}

resource "aws_route53_record" "app_aws_weighted" {
  count = var.azure_dns_mode == "weighted" ? 1 : 0

  zone_id        = module.dns.zone_id
  name           = var.domain_name
  type           = "CNAME"
  ttl            = 60
  records        = [module.alb.alb_dns_name]
  set_identifier = "aws"

  weighted_routing_policy {
    weight = 80
  }

  health_check_id = aws_route53_health_check.aws[0].id

  depends_on = [
    aws_route53_record.app,
    aws_route53_record.app_azure_validation,
    azurerm_container_app_custom_domain.app,
  ]
}

resource "aws_route53_record" "app_azure_weighted" {
  count = var.azure_dns_mode == "weighted" ? 1 : 0

  zone_id        = module.dns.zone_id
  name           = var.domain_name
  type           = "CNAME"
  ttl            = 60
  records        = [module.azure_container_app[0].app_fqdn]
  set_identifier = "azure"

  weighted_routing_policy {
    weight = 20
  }

  health_check_id = aws_route53_health_check.azure[0].id

  depends_on = [
    aws_route53_record.app,
    aws_route53_record.app_azure_validation,
    azurerm_container_app_custom_domain.app,
  ]
}