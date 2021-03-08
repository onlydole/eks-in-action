resource "kubernetes_deployment" "database_api" {
  metadata {
    name      = "database-api"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "database-api"
      }
    }

    template {
      metadata {
        labels = {
          name = "database-api"
        }
      }

      spec {
        container {
          name  = "database-api"
          image = "azdspublic/todo-app-database-api"

          env {
            name  = "MONGO_CONNECTION_STRING"
            value = "mongodb://todos-db"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "database_api" {
  metadata {
    name      = "database-api"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      name = "database-api"
    }
  }
}
