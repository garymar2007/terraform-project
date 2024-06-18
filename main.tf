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
resource "aws_vpc" "my-first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = {
    Name = "production-vpc"
  }
}

resource "aws_vpc" "my-second-vpc" {
  cidr_block = "10.1.0.0/16"
  tags       = {
    Name = "dev-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.my-first-vpc.id
  cidr_block = "10.0.0.0/24"
  tags       = {
    Name = "production-subnet"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.my-second-vpc.id
  cidr_block = "10.1.1.0/24"
  tags       = {
    Name = "dev-subnet"
  }
}
