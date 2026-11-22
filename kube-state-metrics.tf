# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "kube_state_metrics" {
  name = "kube-state-metrics"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  namespace  = kubernetes_namespace_v1.kube_state_metrics.metadata[0].name
  version    = "4.13.0"
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1
resource "kubernetes_namespace_v1" "kube_state_metrics" {
  metadata {
    annotations = {
      name = "kube-state-metrics"
    }
    name = "kube-state-metrics"
  }
}

# kubernetes_namespace is deprecated in provider v3. Move existing state to
# kubernetes_namespace_v1 without recreating the namespace.
moved {
  from = kubernetes_namespace.kube_state_metrics
  to   = kubernetes_namespace_v1.kube_state_metrics
}
