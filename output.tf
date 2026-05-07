output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aca_url" {
  value = azurerm_container_app.zap_mcp.latest_revision_fqdn
}
