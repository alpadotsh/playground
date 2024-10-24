provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {

  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.6.12"

  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  atomic = true
  wait   = true

  values = [
    file("${path.module}/argocd-values.yaml")
  ]
}

data "kubernetes_secret" "argocd-initial-admin-secret" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

output "argocd-initial-admin-password" {
  sensitive = true
  value     = data.kubernetes_secret.argocd-initial-admin-secret.data.password
}


