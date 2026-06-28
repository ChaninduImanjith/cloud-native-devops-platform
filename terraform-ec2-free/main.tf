provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Automatically create an SSH Key Pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf_key" {
  key_name   = "cloud-native-free-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "tf_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "cloud-native-free-key.pem"
  file_permission = "0400"
}

# Security Group to allow traffic
resource "aws_security_group" "ec2_sg" {
  name        = "cloud-native-devops-ec2-sg"
  description = "Allow SSH, Frontend (3000) and Backend (5000)"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "React Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node.js Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.tf_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # User Data Script to automatically install Docker, clone repo, and run app
  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              apt-get update -y
              
              # Install Docker, Docker Compose, and Git
              apt-get install -y docker.io docker-compose git
              
              # Start and enable Docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              
              # Clone the repository
              cd /home/ubuntu
              git clone https://github.com/ChaninduImanjith/cloud-native-devops-platform.git
              
              # Fix permissions
              chown -R ubuntu:ubuntu cloud-native-devops-platform
              
              # Run the application
              cd cloud-native-devops-platform
              docker-compose up --build -d
              EOF

  tags = {
    Name = "CloudNativeDevOps-FreeServer"
  }
}
