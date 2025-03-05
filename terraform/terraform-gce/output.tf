output "host_name" {
  value = google_compute_instance.tf-demo-gcp-instance-1.name
}

output "public_ip" {
  value = google_compute_instance.network_interface.access_config.nat_ip
}