provider "aws" {
  region = "us-east-1"
}

# Create a new EC2 instance
resource "aws_instance" "my-first-server" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  tags = {
    Name = "my-first-server"
  }
}
