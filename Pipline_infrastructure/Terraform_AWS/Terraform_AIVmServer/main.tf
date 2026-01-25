
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "AI-VPC"
    Project = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "AI-IGW"
    Project = var.project_name
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"  # Using hardcoded zone suffix

  tags = {
    Name = "AI-Public-Subnet"
    Project = var.project_name
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "AI-Public-RT"
    Project = var.project_name
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "ai_sg" {
  name        = "AI-Server-SG"
  description = "Security group for AI VM Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AI-Server-SG"
    Project = var.project_name
  }
}

# Data source for latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair
resource "aws_key_pair" "ai_key" {
  key_name   = "AI-Server-Key"
  public_key = var.ssh_public_key

  tags = {
    Name = "AI-Server-Key"
    Project = var.project_name
  }
}

# Elastic IP
resource "aws_eip" "ai_eip" {
  domain = "vpc"
  instance = aws_instance.ai_server.id

  tags = {
    Name = "AI-Server-EIP"
    Project = var.project_name
  }

  depends_on = [aws_internet_gateway.igw]
}

# EC2 Instance
resource "aws_instance" "ai_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.xlarge"  # AWS equivalent to Azure Standard_D4s_v3 (4 vCPU, 16GB RAM)
  key_name      = aws_key_pair.ai_key.key_name
  
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ai_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 256
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "AI-VM-Server"
    Project = var.project_name
  }
}

# Outputs
output "public_ip" {
  description = "Public IP address of the AI Server"
  value       = aws_eip.ai_eip.public_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.ai_server.id
}

output "vm_admin_username" {
  description = "VM Admin Username"
  value       = "ubuntu"
}