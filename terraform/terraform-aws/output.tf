output "host_name" {
  value = aws_instance.app-server.tags.Name
}