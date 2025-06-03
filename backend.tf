terraform {
    backend "azurerm" {
      resource_group_name   = "tfstate"
      storage_account_name  = "tfstateax0yr"
      container_name        = "tfstate"
      key                   = "terraform.tfstate"
    }
}