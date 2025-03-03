terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "fredsonstorage"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}

data "template_file" "script" {
  template = file("windows_userdata.ps1")
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}

resource "azurerm_resource_group" "tfrg" {
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_virtual_network" "tfvn" {
  name                = var.vn_name
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  address_space       = var.vn_address_space
}

resource "azurerm_subnet" "tfsubnet" {
  name                 = var.sn_name
  resource_group_name  = azurerm_resource_group.tfrg.name
  virtual_network_name = azurerm_virtual_network.tfvn.name
  address_prefixes     = var.sn_prefixes
}

resource "azurerm_public_ip" "tfpubip" {
  name                = var.pi_name
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  allocation_method   = var.pi_method
}

resource "azurerm_network_security_group" "tfnsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "WINRM"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

      security_rule {
    name                       = "RDP"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "tfni" {
  name                = var.nic_name
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  ip_configuration {
    name                          = var.nic_ip_name
    subnet_id                     = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfpubip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tfnga" {
  network_interface_id      = azurerm_network_interface.tfni.id
  network_security_group_id = azurerm_network_security_group.tfnsg.id
}

resource "azurerm_windows_virtual_machine" "app-server" {
  name                            = var.vm_name
  location                        = azurerm_resource_group.tfrg.location
  resource_group_name             = azurerm_resource_group.tfrg.name
  network_interface_ids           = [azurerm_network_interface.tfni.id]
  size                            = var.vm_size
  admin_username                  = "fredson"
  admin_password                  = "{{ ansible_admin_pass }}"

  custom_data = data.template_cloudinit_config.config.rendered

  # user_data = file("windows_userdata.ps1")

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment      = "dev"
    owner            = "fredson"
    operating_system = "Windows"
  }
}
