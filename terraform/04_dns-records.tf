
#
# Default Ingress A Records
#
resource "azurerm_dns_a_record" "ingress_a_record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.cluster_dns_zone.name
  resource_group_name = azurerm_dns_zone.cluster_dns_zone.resource_group_name
  ttl                 = 300

  target_resource_id = azurerm_public_ip.default_ingress_ip.id

  depends_on = [azurerm_public_ip.default_ingress_ip, azurerm_dns_zone.cluster_dns_zone]
}

#
# Default Egress A Record
#
resource "azurerm_dns_a_record" "egress_a_record" {
  name                = local.default_egress_name
  zone_name           = azurerm_dns_zone.cluster_dns_zone.name
  resource_group_name = azurerm_dns_zone.cluster_dns_zone.resource_group_name
  ttl                 = 300

  target_resource_id = azurerm_public_ip.default_egress_ip.id

  depends_on = [azurerm_public_ip.default_egress_ip, azurerm_dns_zone.cluster_dns_zone]

  tags = {
    environment = var.deployment.name
    origin      = "tf:resource"
  }
}
