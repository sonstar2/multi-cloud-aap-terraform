variable "gcp_project" {
 type        = string
 description = "Project Name"
 default     = "openenv-vczht"
}

variable "region" {
 type        = string
 description = "Region Name"
 default     = "asia-northeast3"
}

variable "zone" {
 type        = string
 description = "Zone Name"
 default     = "asia-northeast3-a"
}

variable "machine_type" {
 type        = string
 description = "Machine Type"
 default     = "e2-micro"
}

variable "image" {
 type        = string
 description = "OS Image"
 default     = "debian-11-bullseye-v20240110"
}

variable "vm_name" {
 type        = string
 description = "Virtual Machine Name"
 default     = "gcplinux"
}