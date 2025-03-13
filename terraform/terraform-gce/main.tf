terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }

  backend "gcs" {
    bucket  = "ansible_tfstate-bucket"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project
  region = var.region
  zone = var.zone
}

# Create a network
resource "google_compute_network" "ipv6net" {
  provider = google
  name = "ipv6net"
  auto_create_subnetworks = false
}
# Create a subnet with IPv6 capabilities
resource "google_compute_subnetwork" "ipv6subnet" {
  provider = google
  name = "ipv6subnet"
  network = google_compute_network.ipv6net.id
  ip_cidr_range = "10.0.0.0/8"
  stack_type = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}
# Allow SSH from all IPs (insecure, but ok for this tutorial)
resource "google_compute_firewall" "firewall" {
  provider = google
  name    = "firewall"
  network = google_compute_network.ipv6net.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
}

# resource "google_compute_address" "static-ip" {
#   provider = google
#   name = "static-ip"
#   address_type = "EXTERNAL"
#   network_tier = "PREMIUM"
# }

resource "google_compute_instance" "app-server" {
# resource "google_compute_instance" "tf-demo-gcp-instance-1" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone = var.zone

  network_interface {
    network = google_compute_network.ipv6net.id
    subnetwork = google_compute_subnetwork.ipv6subnet.id
    stack_type = "IPV4_IPV6"
    access_config {
      # nat_ip = google_compute_address.static-ip.address
      # network_tier = "PREMIUM"
    }

    ipv6_access_config {
      network_tier  = "PREMIUM"
    }
  }

  boot_disk {
    initialize_params {
      image = var.image
      labels = {
        my_label = "value"
      }
    }
  }
  tags = ["debian", "linux"]
}

resource "google_compute_project_metadata" "my_ssh_key" {
  metadata = {
    ssh-keys = <<EOF
      fredson:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpWNx8FkSVz4dcRRxkN5si5uNcHT9FhpqO59WiHONGUzHThM3L+q10XLMYoHdF/2Ef0HPuu9lGnEJPgKtfZaYcwrTWu5IQypOK7M8Gn+ot0yxiTyMzsXak/zrTlRA69NOwMApwe0wFmPTJkFueIwFclAPBUExX0NH/DdJei0Fv8hjrZTDzZvROxG+fULd12baMgBxzT92kDv0NDa+gp3wtZ0xFJqoLoUcCKW68B1DhroKdbh+uvJh4zCaDnoHSNmV8MwOhnflu3R7xJzpepRVa3OpFnsVPBbIVkyKXB9nMDdPeALdfG343nXx5Hkcfqnfiy+mk9ELb8hoJkCAMT9XRnUVOEcoY8BTkL7ooIk5R3gAXqswHgMblHlhoJ0bD0xXJxTYLYjovW3DC7sxcG1lxaQZRIMIAYfy0iJOTLZu/bjw2viqeujBRc/DVMSMFNo7eU2eZhb95FkvzwORzBiAOb5pWyDRDV9t7OLR+DFSwwEd66H9cQzfisq7Llg8Gx4k= fredson@mson-mac
    EOF
  }
}