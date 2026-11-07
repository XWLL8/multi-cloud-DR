output "application_url" {
  description = "HTTPS URL for the application"
  value       = "https://${var.domain_name}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the application VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL of the application ECR repository"
  value       = module.ecs.repository_url
}

output "ecr_repository_name" {
  description = "Name of the application ECR repository"
  value       = module.ecs.repository_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster used by the deployment workflow"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service, or empty when the service is disabled"
  value       = module.ecs.service_name
}

output "azure_acr_login_server" {
  description = "Azure Container Registry login server"
  value       = module.azure_container_registry.login_server
}

output "azure_acr_name" {
  description = "Azure Container Registry name"
  value       = module.azure_container_registry.registry_name
}

output "azure_container_image_repository" {
  description = "Azure Container Registry image repository without a tag"
  value       = "${module.azure_container_registry.login_server}/${var.project_name}"
}

output "azure_resource_group_name" {
  description = "Azure resource group used by the deployment workflow"
  value       = azurerm_resource_group.dr.name
}

output "azure_container_app_name" {
  description = "Azure Container App name, or empty when the app is disabled"
  value       = try(module.azure_container_app[0].app_name, "")
}

output "azure_image_uri" {
  description = "Azure Container Registry image URI for the configured tag"
  value       = "${module.azure_container_registry.login_server}/${var.project_name}:${var.azure_image_tag}"
}

output "azure_container_app_url" {
  description = "Default Azure Container App URL after the app has been enabled"
  value       = try("https://${module.azure_container_app[0].app_fqdn}", null)
}