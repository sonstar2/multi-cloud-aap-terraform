terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }

  # backend "gcs" {
  #   bucket         = "ansible_tfstate-bucket"
  #   prefix         = "terraform.tfstate"
  # }
}

provider "google" {
  # credentials = var.gcp_credentials_path
  project = var.gcp_project
  region = var.region
  zone = var.zone
}

resource "google_compute_instance" "tf-demo-gcp-instance-1" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_project_metadata" "my_ssh_key" {
  metadata = {
    ssh-keys = <<EOF
      fredson:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpWNx8FkSVz4dcRRxkN5si5uNcHT9FhpqO59WiHONGUzHThM3L+q10XLMYoHdF/2Ef0HPuu9lGnEJPgKtfZaYcwrTWu5IQypOK7M8Gn+ot0yxiTyMzsXak/zrTlRA69NOwMApwe0wFmPTJkFueIwFclAPBUExX0NH/DdJei0Fv8hjrZTDzZvROxG+fULd12baMgBxzT92kDv0NDa+gp3wtZ0xFJqoLoUcCKW68B1DhroKdbh+uvJh4zCaDnoHSNmV8MwOhnflu3R7xJzpepRVa3OpFnsVPBbIVkyKXB9nMDdPeALdfG343nXx5Hkcfqnfiy+mk9ELb8hoJkCAMT9XRnUVOEcoY8BTkL7ooIk5R3gAXqswHgMblHlhoJ0bD0xXJxTYLYjovW3DC7sxcG1lxaQZRIMIAYfy0iJOTLZu/bjw2viqeujBRc/DVMSMFNo7eU2eZhb95FkvzwORzBiAOb5pWyDRDV9t7OLR+DFSwwEd66H9cQzfisq7Llg8Gx4k= fredson@mson-mac
    EOF
  }
}