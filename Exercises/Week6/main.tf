terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. RANDOM ID (For unique bucket names)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. STORAGE (S3)
resource "aws_s3_bucket" "photo_bucket" {
  bucket = "photo-app-${random_id.bucket_suffix.hex}"
}

# 3. NETWORK (Security Group)
resource "aws_security_group" "web_sg" {
  name = "photo_app_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

# 4. COMPUTE (EC2)
resource "aws_instance" "app_server" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04 (us-east-1)
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # THE MAGIC: Terraform fills in the variable BEFORE sending the script to AWS
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Photo App Configured</h1><p>Upload Target: ${aws_s3_bucket.photo_bucket.id}</p>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "PhotoApp-Server"
  }
}

output "website_url" {
  value = "http://${aws_instance.app_server.public_ip}"
}
