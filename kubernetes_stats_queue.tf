resource "kubernetes_deployment" "stats_queue" {
  metadata {
    name      = "stats-queue"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "stats-queue"
      }
    }

    template {
      metadata {
        labels = {
          name = "stats-queue"
        }
      }

      spec {
        container {
          name  = "queue"
          image = "rabbitmq:3-alpine"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "stats_queue" {
  metadata {
    name      = "stats-queue"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    port {
      port        = 5672
      target_port = "5672"
    }

    selector = {
      name = "stats-queue"
    }
  }
}
