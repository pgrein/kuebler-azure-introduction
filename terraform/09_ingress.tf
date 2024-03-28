#
# Add Nginx Ingress using Helm Chart
#
resource "kubernetes_namespace" "default_ingress_namespace" {
  metadata {
    name = "ingress-default"
  }
  depends_on = [azurerm_kubernetes_cluster.cluster]
}


resource "helm_release" "default_nginx_ingress" {
  name       = "ingress-default"
  repository = "https://marketplace.azurecr.io/helm/v1/repo"
  chart      = "nginx-ingress-controller"

  namespace = kubernetes_namespace.default_ingress_namespace.metadata.0.name

  set {
    name  = "service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.tolerations"
    value = yamlencode([
      {
        key      = "CriticalAddonsOnly"
        operator = "Exists"
        effect   = "NoSchedule"
      }
    ])
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "service.loadBalancerIP"
    value = azurerm_public_ip.default_ingress_ip.ip_address
  }

  depends_on = [kubernetes_namespace.default_ingress_namespace]
}
