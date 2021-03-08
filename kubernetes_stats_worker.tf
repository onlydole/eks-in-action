resource "kubernetes_deployment" "stats_worker" {
  metadata {
    name      = "stats-worker"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "stats-worker"
      }
    }

    template {
      metadata {
        labels = {
          name = "stats-worker"
        }
      }

      spec {
        container {
          name  = "stats-worker"
          image = "azdspublic/todo-app-stats-worker"

          env {
            name  = "STATS_QUEUE_URI"
            value = "amqp://stats-queue"
          }

          env {
            name  = "REDIS_HOST"
            value = "stats-cache"
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}
