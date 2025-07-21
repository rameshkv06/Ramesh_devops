provider "aws" {

  region = "us-east-1"  # Update to your desired region

}
 
resource "aws_vpc" "main_vpc" {

  cidr_block           = "10.0.0.0/16"

  enable_dns_support   = true

  enable_dns_hostnames = true

  tags = {

    Name = "main-vpc"

  }

}
 
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main_vpc.id

  tags = {

    Name = "main-igw"

  }

}
 
resource "aws_subnet" "public_subnet" {

  vpc_id                  = aws_vpc.main_vpc.id

  cidr_block              = "10.0.1.0/24"

  map_public_ip_on_launch = true

  availability_zone       = "us-east-1a"

  tags = {

    Name = "public-subnet"

  }

}
 
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {

    Name = "public-route-table"

  }

}
 
resource "aws_route_table_association" "public_association" {

  subnet_id      = aws_subnet.public_subnet.id

  route_table_id = aws_route_table.public_rt.id

}
 
resource "aws_security_group" "web_sg" {

  name        = "web-sg"

  description = "Allow HTTP and SSH"

  vpc_id      = aws_vpc.main_vpc.id
 
  ingress {

    description = "HTTP"

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }
 
  ingress {

    description = "SSH"

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
 
  tags = {

    Name = "web-sg"

  }

}
 
resource "aws_instance" "web_server" {

  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI in us-east-1

  instance_type = "t2.micro"

  subnet_id     = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

 
  user_data = <<-EOF

              #!/bin/bash

              yum update -y

              yum install -y httpd

              systemctl start httpd

              systemctl enable httpd

              echo "<h1>Hello from Terraform Web Server</h1>" > /var/www/html/index.html

              EOF
 
  tags = {

    Name = "web-server"

  }

}

 