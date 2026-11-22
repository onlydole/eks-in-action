# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "kube_state_metrics" {
  name = "kube-state-metrics"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  namespace  = kubernetes_namespace.kube_state_metrics.metadata[0].name
  version    = "4.13.0"
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace
resource "kubernetes_namespace" "kube_state_metrics" {
  metadata {
    annotations = {
      name = "kube-state-metrics"
    }
    name = "kube-state-metrics"
  }
}
