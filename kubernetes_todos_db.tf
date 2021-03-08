resource "kubernetes_deployment" "todos_db" {
  metadata {
    name      = "todos-db"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    selector {
      match_labels = {
        name = "todos-db"
      }
    }

    template {
      metadata {
        labels = {
          name = "todos-db"
        }
      }

      spec {
        container {
          name  = "todos-db"
          image = "mongo:4"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "todos_db" {
  metadata {
    name      = "todos-db"
    namespace = kubernetes_namespace.todo_app.id
  }

  spec {
    port {
      port        = 27017
      target_port = "27017"
    }

    selector = {
      name = "todos-db"
    }
  }
}
