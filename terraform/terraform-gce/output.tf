output "host_name" {
  value = google_compute_instance.app-server.name
}

# output "public_ip" {
#   value = google_compute_address.static-ip.address
# }