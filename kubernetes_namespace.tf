resource "kubernetes_namespace" "todo_app" {
  metadata {
    name = "todo-app"
  }
}
