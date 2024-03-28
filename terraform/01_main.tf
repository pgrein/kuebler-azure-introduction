variable "deployment" {
  type = object({
    name = string
    location = string
  })

  default = {
    name = " "
    location = "West Europe"
  }

  validation {
    condition = can(regex("[^\\s]", var.deployment.name))
    error_message = "The app.name cannot contain spaces."
  }
}

variable "network" {
  type = object({
    vnet_address_space = string
    primary_subnet_address_prefix = string
  })

  default = {
    vnet_address_space = "10.0.0.0/16"
    primary_subnet_address_prefix = "10.0.0.0/17"
  }
}

variable "location" {
  type = string
  default = "West Europe"
}

variable "administration_access" {
  type = object({
    ip_ranges = list(string)
  })

  default = {
    ip_ranges = [
      "185.207.241.126",  # Pierre Dahoim
      "212.184.30.64/27"  # Star
    ]
  }
}

#
# Local variables
#

locals {
  location_label = lower(replace(var.deployment.location, " ", ""))
  deployment_name_cleaned = lower(replace(var.deployment.name, "/[ -_]/", ""))
}

#
# Main App Resource Group
#
resource "azurerm_resource_group" "cluster_resources" {
  name = "${var.deployment.name}-${local.location_label}-cluster-rg"
  location = var.deployment.location

  tags = {
    environment = var.deployment.name
    origin = "tf:resource"
  }
}

#resource "azurerm_resource_group" "cluster_managed_resources" {
#  name = "${var.deployment.name}-${local.location_label}-cluster-managed-rg"
#  location = var.deployment.location
#
#  tags = {
#    environment = var.deployment.name
#    origin = "tf:resource"
#  }
#}

#
# App VNet
#
resource "azurerm_virtual_network" "primary_vnet" {
  name = "${var.deployment.name}-${local.location_label}-primary-vnet"
  address_space = [var.network.vnet_address_space]
  location = var.deployment.location
  resource_group_name = azurerm_resource_group.cluster_resources.name

  tags = {
    environment = var.deployment.name
    origin = "tf:resource"
  }
}

#
# Primary App Subnet
#
resource "azurerm_subnet" "defaultnp_subnet" {
  name = "${var.deployment.name}-${local.location_label}-aks-defaultnp-subnet"
  resource_group_name = azurerm_resource_group.cluster_resources.name
  virtual_network_name = azurerm_virtual_network.primary_vnet.name
  address_prefixes = [var.network.primary_subnet_address_prefix]

  service_endpoints = ["Microsoft.Storage"]
}




#
# Outputs
#
output "primary_vnet_id" {
  value = azurerm_virtual_network.primary_vnet.id
}

output "defaultnp_subnet" {
  value = azurerm_subnet.defaultnp_subnet.id
}
