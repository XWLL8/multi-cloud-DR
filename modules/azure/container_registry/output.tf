output "registry_id" {
  value = azurerm_container_registry.container_registry.id
}

output "registry_name" {
  value = azurerm_container_registry.container_registry.name
}

output "login_server" {
  value = azurerm_container_registry.container_registry.login_server
}

output "identity_id" {
  value = azurerm_user_assigned_identity.registry_pull.id
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.registry_pull.principal_id
}
