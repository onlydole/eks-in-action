resource "kubernetes_deployment" "stats_cache" {
  metadata {
    name      = "stats-cache"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "stats-cache"
      }
    }

    template {
      metadata {
        labels = {
          name = "stats-cache"
        }
      }

      spec {
        container {
          name  = "cache"
          image = "redis:5-alpine"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "stats_cache" {
  metadata {
    name      = "stats-cache"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    port {
      port        = 6379
      target_port = "6379"
    }

    selector = {
      name = "stats-cache"
    }
  }
}
