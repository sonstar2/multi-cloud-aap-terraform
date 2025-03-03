variable "region" {
 type        = string
 description = "Region Name"
 default     = "us-east-2"
}

variable "vpc_cidr" {
 type        = string
 description = "VPC cidr"
 default     = "11.0.0.0/16"
}

variable "subnet_private_cidr" {
 type        = string
 description = "Subnet cidr"
 default     = "11.0.2.0/24"
}

variable "subnet_public_cidr" {
 type        = string
 description = "Subnet cidr"
 default     = "11.0.1.0/24"
}

variable "availability_zone" {
 type        = string
 description = "Subnet cidr"
 default     = "us-east-2a"
}

variable "vm_name" {
 type        = string
 description = "Virtual Machine Name"
 default     = "rhel9app"
}