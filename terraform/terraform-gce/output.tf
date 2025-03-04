output "app-server" {
  value = aws_instance.app-server.tags.Name
}