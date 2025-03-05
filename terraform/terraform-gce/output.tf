output "host_name" {
  value = google_compute_instance.tf-demo-gcp-instance-1.name
}

# output "public_ip" {
#   value = google_compute_address.static-ip.address
# }