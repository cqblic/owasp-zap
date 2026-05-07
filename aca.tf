resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}-zap-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = "${var.prefix}-zap-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_container_app" "zap_mcp" {
  name                         = "zap-mcp-server"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "zap-mcp"
      image  = "${azurerm_container_registry.acr.login_server}/zap-mcp:latest"
      cpu    = 1.0
      memory = "2Gi"

      env {
        name  = "ZAP_API_KEY"
        value = "secret-key-123" # In production, use a secret reference
      }
    }

    min_replicas = 0
    max_replicas = 1
  }

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.acr.admin_password
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000 # MCP server (Express)
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

output "aca_url" {
  value = azurerm_container_app.zap_mcp.latest_revision_fqdn
}
