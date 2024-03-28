#
# Input Variables
#
variable "ssh_public_key" {
  type = string
}

variable "cluster" {
  type = object({
    service_cidr = string
    dns_service_ip = string
  })

  default = {
    service_cidr = "172.18.0.0/16"
    dns_service_ip = "172.18.0.10"
  }
}

variable "default_node_pool" {
  type = object({
    node_vm_size = string
    os_disk_type = string
    os_disk_size = number
    max_pods = number
    min_node_count = number
    max_node_count = number
  })

  default = {
    node_vm_size = "Standard_E2as_v5"
    os_disk_type = "Managed"
    os_disk_size = "128"
    max_pods = 110
    min_node_count = 1
    max_node_count = 3
  }
}

variable "user_node_pool" {
  type = object({
    node_vm_size = string
    os_disk_type = string
    os_disk_size = number
    max_pods = number
    min_node_count = number
    max_node_count = number
  })

  default = {
    node_vm_size = "Standard_E8as_v5"
    os_disk_type = "Managed"
    os_disk_size = "256"
    max_pods = 110
    min_node_count = 1
    max_node_count = 3
  }
}


#
# Cluster
# 
resource "azurerm_kubernetes_cluster" "cluster" {
  name = "${var.deployment.name}-${local.location_label}"
  location = azurerm_resource_group.cluster_resources.location
  resource_group_name = azurerm_resource_group.cluster_resources.name
  dns_prefix = var.deployment.name

  # Block access to all other than the given ip ranges
  //  api_server_authorized_ip_ranges = var.administration_access.ip_ranges

  # Resource group where the aks managed stuff will be put into
  node_resource_group = "${var.deployment.name}-${local.location_label}-cluster-managed-rg"

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      # Key to access the nodes for debugging (if necessary)
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    network_plugin      = "azure"
    dns_service_ip      = var.cluster.dns_service_ip
    service_cidr        = var.cluster.service_cidr
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.default_egress_ip.id]
    }
  }

  default_node_pool {
    name = "default"
    vm_size           = var.default_node_pool.node_vm_size
    os_disk_type      = var.default_node_pool.os_disk_type
    os_disk_size_gb   = var.default_node_pool.os_disk_size
    max_pods          = var.default_node_pool.max_pods
    node_count        = var.default_node_pool.min_node_count

    enable_auto_scaling          = true
    max_count                    = var.default_node_pool.max_node_count
    min_count                    = var.default_node_pool.min_node_count

    vnet_subnet_id = azurerm_subnet.defaultnp_subnet.id
  }

  auto_scaler_profile {
    max_unready_nodes             = 1
    skip_nodes_with_local_storage = false
    skip_nodes_with_system_pods   = false
  }

  service_principal {
    client_id = var.service_principal.client_id
    client_secret = var.service_principal.client_secret
  }

  depends_on = [
    azurerm_resource_group.cluster_resources,
    azurerm_public_ip.default_egress_ip,
  ]

  tags = {
    environment = var.deployment.name
    origin = "tf:resource"
  }
}



#
# Customer Node Pool
#
resource "azurerm_kubernetes_cluster_node_pool" "user_node_pool" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id

  vm_size         = var.user_node_pool.node_vm_size
  os_disk_type    = var.user_node_pool.os_disk_type
  os_disk_size_gb = var.user_node_pool.os_disk_size
  max_pods        = var.user_node_pool.max_pods
  node_count      = var.user_node_pool.min_node_count

  enable_auto_scaling = true
  max_count           = var.user_node_pool.max_node_count
  min_count           = var.user_node_pool.min_node_count

  vnet_subnet_id      = azurerm_subnet.defaultnp_subnet.id

  depends_on = [
    azurerm_kubernetes_cluster.cluster
  ]

  tags = {
    environment = var.deployment.name
    origin = "tf:resource"
  }
}
