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

# Auto-lookup latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "infracost-${random_id.suffix.hex}"
  tags = { Project = "InfracostDemo" }
}

resource "aws_instance" "demo_instance" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  tags = { Project = "InfracostDemo" }
}
