resource "kubernetes_deployment" "stats_api" {
  metadata {
    name      = "stats-api"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "stats-api"
      }
    }

    template {
      metadata {
        labels = {
          name = "stats-api"
        }
      }

      spec {
        container {
          name  = "stats-api"
          image = "azdspublic/todo-app-stats-api"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "stats_api" {
  metadata {
    name      = "stats-api"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      name = "stats-api"
    }
  }
}
