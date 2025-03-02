variable "rg_name" {
 type        = string
 description = "Resource Group Name"
 default     = "fredson-terraform-rg"
}

variable "rg_location" {
 type        = string
 description = "Resource Group Location"
 default     = "Australia-East"
}

variable "vn_name" {
 type        = string
 description = "Virtual Network Name"
 default     = "fredson-terraform-vnet"
}

variable "vn_address_space" {
 type        = list(string)
 description = "Virtual Network Address Space"
 default     = ["10.0.0.0/16"]
}

variable "sn_name" {
 type        = string
 description = "Subnet Name"
 default     = "fredson-terraform-subnet"
}

variable "sn_address_space" {
 type        = list(string)
 description = "Subnet Address Prefixes"
 default     = ["10.0.2.0/24"]
}

variable "pi_name" {
 type        = string
 description = "Public IP Name"
 default     = "fredson-terraform-public-ip"
}

variable "pi_method" {
 type        = string
 description = "Public IP Method"
 default     = "Static"
}

variable "ngs_name" {
 type        = string
 description = "Network Security Group Name"
 default     = "fredson-terraform-nsg"
}

variable "nic_name" {
 type        = string
 description = "Network Interface Name"
 default     = "fredson-terraform-nic"
}

variable "nic_ip_name" {
 type        = string
 description = "IP Configuration Name"
 default     = "fredson-terraform-ip-config"
}

variable "vm_name" {
 type        = string
 description = "Virtual Machine Name"
 default     = "winapp.fredson.dev"
}

variable "vm_size" {
 type        = string
 description = "Virtual Machine Size"
 default     = "Standard_B1s"
}

