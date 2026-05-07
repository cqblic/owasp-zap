provider "azurerm" {
  features {
  }
  subscription_id                 = "531799f9-99d5-4a8a-b8ad-6bb951d2fc7d"
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
}
