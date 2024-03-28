

variable "parent_dns_zone" {
  type = object({
    name = string
    resource_group_name = string
  })

  default = {
    name = "az.ssys-e.com"
    resource_group_name = "devcom-rg"
  }
}

data "azurerm_resource_group" "devcom_resources" {
  name                = var.parent_dns_zone.resource_group_name
}

data "azurerm_dns_zone" "parent_zone" {
  name                = var.parent_dns_zone.name
  resource_group_name = data.azurerm_resource_group.devcom_resources.name
}

locals {
  deployment_dns_zone_name = "${var.deployment.name}.${data.azurerm_dns_zone.parent_zone.name}"
}

resource "azurerm_dns_zone" "cluster_dns_zone" {
  name                = local.deployment_dns_zone_name
  resource_group_name = azurerm_resource_group.cluster_resources.name
}

# create ns record for sub-zone in parent zone
resource "azurerm_dns_ns_record" "cluster_ns_record" {
  name                = var.deployment.name
  zone_name           = data.azurerm_dns_zone.parent_zone.name
  resource_group_name = data.azurerm_dns_zone.parent_zone.resource_group_name
  ttl                 = 3600

  records = azurerm_dns_zone.cluster_dns_zone.name_servers
}
