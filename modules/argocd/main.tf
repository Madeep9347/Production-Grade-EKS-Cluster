resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.argocd_namespace

  create_namespace = true

  # Keep Argo CD internal (Ingress later)
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Disable admin password auto-rotation (learning)
  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = ""
  }

  # Improve reconciliation
  set {
    name  = "controller.args.appResyncPeriod"
    value = "30"
  }
}
