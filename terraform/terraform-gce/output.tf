output "host_name" {
  value = google_compute_instance.tf-demo-gcp-instance-1.tags.Name
}

output "public_ip" {
  value = network_interface.access_config.nat_ip
}