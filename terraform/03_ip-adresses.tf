locals {
  default_ingress_name   = "default-ingress"
  default_egress_name    = "default-egress"

  default_egress_fqdn    = "${local.default_egress_name}.${azurerm_dns_zone.cluster_dns_zone.name}"
}

#
# Default Ingress IPs
#
resource "azurerm_public_ip" "default_ingress_ip" {
  name                = "${var.deployment.name}-${local.default_ingress_name}-public-ip"
  domain_name_label   = "${var.deployment.name}-${local.default_ingress_name}"
  location            = azurerm_resource_group.cluster_resources.location
  resource_group_name = azurerm_kubernetes_cluster.cluster.node_resource_group
  allocation_method   = "Static"

  # AKS load balancer capable IP address must be "Standard", not "Basic"
  sku = "Standard"

  depends_on = [azurerm_resource_group.cluster_resources, azurerm_kubernetes_cluster.cluster]

  tags = {
    environment = var.deployment.name
    origin      = "tf:resource"
  }
}


#
# Default Egress IP
#

resource "azurerm_public_ip" "default_egress_ip" {
  name                = "${var.deployment.name}-${local.default_egress_name}-public-ip"
  domain_name_label   = "${var.deployment.name}-${local.default_egress_name}"
  location            = azurerm_resource_group.cluster_resources.location
  resource_group_name = azurerm_resource_group.cluster_resources.name
  allocation_method   = "Static"

  # Point to traffic manager fqdn - Not working because of the necessity that ingress ips need to be in managed-rg and managed-rgs cannot pre-created before cluster creation.
  #  reverse_fqdn = "${azurerm_dns_zone.cluster_dns_zone.name}."

  # AKS load balancer capable IP address must be "Standard", not "Basic"
  sku = "Standard"

  depends_on = [azurerm_resource_group.cluster_resources]

  tags = {
    environment = var.deployment.name
    origin      = "tf:resource"
  }
}


output "default_ingress_ip" {
  value = azurerm_public_ip.default_ingress_ip.ip_address
}

output "default_egress_ip" {
  value = azurerm_public_ip.default_egress_ip.ip_address
}
