resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = random_pet.rg_name.id

  tags = {
    source  = "tofu"
    creator = "carlos@blic.llc"
  }
}

# update dns zone to use the FQDN of the Container App
resource "azurerm_dns_cname_record" "record" {
  name                = var.vm_name
  resource_group_name = var.dns_resource_group_name
  zone_name           = var.dns_zone
  ttl                 = 3600
  record              = azurerm_container_app.zap_mcp.latest_revision_fqdn
}
