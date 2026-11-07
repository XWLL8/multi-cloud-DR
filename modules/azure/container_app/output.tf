output "app_url" {
  description = "Azure Container App URL"
  value       = "https://${azurerm_container_app.container_app.ingress[0].fqdn}"
}

output "app_name" {
  value = azurerm_container_app.container_app.name
}

output "app_id" {
  value = azurerm_container_app.container_app.id
}

output "app_fqdn" {
  value = azurerm_container_app.container_app.ingress[0].fqdn
}

output "custom_domain_verification_id" {
  value = azurerm_container_app.container_app.custom_domain_verification_id
}

output "environment_id" {
  value = azurerm_container_app_environment.container_app_env.id
}