provider "aws" {
  region = "us-east-1"

}

# Create a new EC2 instance
#resource "aws_instance" "my-first-server" {
#  ami           = "ami-04b70fa74e45c3917"
#  instance_type = "t2.micro"
#  tags = {
#    Name = "my-first-server"
#  }
#}

# Create a VPC
#resource "aws_vpc" "my-first-vpc" {
#  cidr_block = "10.0.0.0/16"
#  tags       = {
#    Name = "production-vpc"
#  }
#}
#
#resource "aws_vpc" "my-second-vpc" {
#  cidr_block = "10.1.0.0/16"
#  tags       = {
#    Name = "dev-vpc"
#  }
#}
#
## Create a subnet
#resource "aws_subnet" "subnet1" {
#  vpc_id     = aws_vpc.my-first-vpc.id
#  cidr_block = "10.0.0.0/24"
#  tags       = {
#    Name = "production-subnet"
#  }
#}
#
#resource "aws_subnet" "subnet2" {
#  vpc_id     = aws_vpc.my-second-vpc.id
#  cidr_block = "10.1.1.0/24"
#  tags       = {
#    Name = "dev-subnet"
#  }
#}

# Practice Project Example
# 1. create VPC
resource "aws_vpc" "practice-project-vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = {
    Name = "practice-project-vpc"
  }
}
#2.	Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.practice-project-vpc.id
  tags = {
    Name = "practice-project-igw"
  }
}
#3.	Create Custom route Table
resource "aws_route_table" "practice-project-rt" {
  vpc_id = aws_vpc.practice-project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block             = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "practice-project-rt"
  }
}

#4.	Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.practice-project-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags              = {
    Name = "practice-project-subnet"
  }
}
#5.	Associate subnet with Route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.practice-project-rt.id
}
#6.	Create Security group to allow port 22, 80, 443
resource "aws_security_group" "practice-project-sg" {
  name        = "allow_web_traffic"
  description = "Allow Web Traffic on port 22, 80, 443"
  vpc_id      = aws_vpc.practice-project-vpc.id
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "practice-project-sg"
  }
}

#7.	Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "practice-project-ni" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.practice-project-sg.id]
}

#8.	Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "practice-project-eip" {
  domain      = "vpc"
  network_interface = aws_network_interface.practice-project-ni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw, aws_instance.practice-project-web-server]
}

output "server_public_ip" {
  value = aws_eip.practice-project-eip.public_ip
}

#9.	Create ubuntu server and install/enable apache2
resource "aws_instance" "practice-project-web-server" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name      = "main-key"
  network_interface {
    network_interface_id = aws_network_interface.practice-project-ni.id
    device_index         = 0
  }
  tags = {
    Name = "practice-project-server"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl enable apache2
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
}

output "server_private_ip" {
  value = aws_instance.practice-project-web-server.private_ip
}

output "server_id" {
  value = aws_instance.practice-project-web-server.id
}
