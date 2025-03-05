output "tf-demo-gcp-instance-1" {
  value = google_compute_instance.tf-demo-gcp-instance-1.tags.Name
}

output "tf-demo-gcp-instance-1" {
  value = network_interface.access_config.nat_ip
}