terraform {
  required_providers {
    azurerm =  "~> 3.97.1"
    kubernetes = "~> 2.27.0"
    helm = "~> 2.12.1"
    time = "~> 0.11.1"
  }
}


provider "azurerm" {
  subscription_id = var.service_principal.subscription_id
  tenant_id = var.service_principal.tenant_id
  client_id = var.service_principal.client_id
  client_secret = var.service_principal.client_secret

  features {}
}

#
# Input Variables
#
variable "service_principal" {
  type = object({
    client_id = string
    client_display_name = string
    client_name = string
    client_secret = string
    subscription_id = string
    tenant_id = string
  })
}
