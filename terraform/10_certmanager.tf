resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [azurerm_kubernetes_cluster.cluster]
}

# Install cert-manager from Helm Chart
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  namespace = kubernetes_namespace.cert_manager_namespace.metadata.0.name

  set {
    name  = "installCRDs"
    value = "true"
  }

#  set {
#    name  = "tolerations"
#    value = yamlencode([
#      {
#        key      = "CriticalAddonsOnly"
#        operator = "Exists"
#        effect   = "NoSchedule"
#      }
#    ])
#  }

  depends_on = [kubernetes_namespace.cert_manager_namespace, helm_release.default_nginx_ingress]
}
