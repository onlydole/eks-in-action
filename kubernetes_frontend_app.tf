resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          name = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "azdspublic/todo-app-frontend"

          env {
            name  = "STATS_QUEUE_URI"
            value = "amqp://stats-queue"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      name = "frontend"
    }

    type = "LoadBalancer"
  }
}
