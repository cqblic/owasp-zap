resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = random_pet.rg_name.id

  tags = {
    source = "tofu"
    creator = "carlos@blic.llc"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  admin_username        = "azureuser"
  eviction_policy       = "Deallocate"
  location              = var.location
  name                  = var.vm_name
  priority              = "Spot"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id] 
  secure_boot_enabled   = true
  size                  = "Standard_DS1_v2"
  vtpm_enabled          = true
  zone                  = "1"
  additional_capabilities {
  }

  admin_ssh_key {
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4Sj0TQd0StXmGIRoMUXt8m/ix9WOq57sqzF5c5hywksM2ZvhVlngX80rxOiS6FZLW2+PN7NjFecbTtxtxrtCvBkXp7L6usQprKkKCpmGPQG8QgWz6dCqRVXjMbpCO6ukJS4C/2K53Y1WsEQq8QN5CNAh9IhVLqtvGGxY2q1knRW9DK8pTpBd8wvC+L0VusydMJkXRlPNcRkNP9pEqYnGCYGqRwpj/FOaQrJgCdvWe5m3cj8Zs2+aIcCKO6jytrN1dTinDIv49DnB4b2acl5LfizEpKyw7CB8/F2I/bMP5kIdFulrgwDxqqFhCc5LMM2YnEH51lM0Q+Ydp2YralWc5SBqtMQ0lX1SXU3bNRULcl6dDbZx8mGu6edd+U0ByazolpfO7LdcXZPPnWHz6XQoK+oePVixhWkyzbgehzPyNUTfRl9ZlrmFjhDCNtSP0T4parRYBGjGsK6bTaGY3/D45i7pMR40PmZXnm6ETSJY88U1rq6LYK13Us22/FQopZ+U= generated-by-azure"
    username   = "azureuser"
  }
  boot_diagnostics {
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
  

  custom_data    = base64encode(data.template_file.user-data.rendered)

  tags = {
    source = "tofu"
    creator = "carlos@blic.llc"
  }
}

# update dns zone to use the public IP address of the VM
resource "azurerm_dns_a_record" "record" {
  name                = var.vm_name
  resource_group_name = var.dns_resource_group_name
  zone_name           = var.dns_zone
  ttl                 = 3600
  records             = [azurerm_public_ip.main.ip_address]
}

# Data template Bash bootstrapping file
data "template_file" "user-data" {
  template = file("${path.module}/user-data.sh")
  vars = {
  }
}
