terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.38"
    }
  }

  backend "s3" {
    bucket         = "aws-test-tf-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}

provider "aws" {
  region     = var.region
}
resource "aws_vpc" "ansiblevpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    "Name" = "Ansible-Terraform-VPC"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.ansiblevpc.id
  cidr_block        = var.subnet_private_cidr
  availability_zone = var.availability_zone
  tags = {
    "Name" = "Ansible-Terraform-Subnet-Private"
  }
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.ansiblevpc.id
  cidr_block        = var.subnet_public_cidr
  availability_zone = var.availability_zone
  tags = {
    "Name" = "Ansible-Terraform-Subnet-Public"
  }
}
resource "aws_route_table" "ansible-rt" {
  vpc_id = aws_vpc.ansiblevpc.id
  tags = {
    "Name" = "Ansible-Terraform-RT"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.ansible-rt.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.ansible-rt.id
}
resource "aws_internet_gateway" "ansible-igw" {
  vpc_id = aws_vpc.ansiblevpc.id
  tags = {
    "Name" = "Ansible-Terraform-IG"
  }
}
resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.ansible-rt.id
  gateway_id             = aws_internet_gateway.ansible-igw.id
}
resource "aws_network_interface" "ansible-nic" {
  subnet_id       = aws_subnet.public.id
  private_ips     = ["11.0.1.120"]
  security_groups = [aws_security_group.web-pub-sg.id]
  tags = {
    "Name" = "Ansible-Terraform-NI"
  }
}

resource "aws_eip" "ip-one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.ansible-nic.id
  depends_on                = [aws_instance.app-server]
  tags = {
    "Name" = "Ansible-Terraform-EIP"
  }
}

resource "aws_security_group" "web-pub-sg" {
  name        = "Ansible_SG"                ### Survey
  description = "allow inbound traffic"
  tags = {
    "Name" = "Ansible-Terraform-SG"
  }
  vpc_id      = aws_vpc.ansiblevpc.id
  ingress {
    description = "from my ip range"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }
}
resource "aws_instance" "app-server" {
  instance_type = "t2.micro"
  ami           = "ami-04f8d0dc7c0ac7a0e"
  network_interface {
    network_interface_id = aws_network_interface.ansible-nic.id
    device_index         = 0
  }
  key_name = "aws-test-key"
  tags = {
      Name = var.vm_name
      owner: "fredson"
      env: "dev"
      operating_system: "RHEL9"
      usage: "fredsondemo"
      }
}


