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

# Grab Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ------------------------------
# SIMPLE EC2 COST DEMO
# ------------------------------
resource "aws_instance" "my_web_app" {
  ami = data.aws_ami.al2023.id

  # <<<<<<<< TRY CHANGING THIS >>>>>>>>
  # t3.micro -> t3.large  
  # t3.micro -> m5.large  
  # t3.micro -> m5.2xlarge  
  instance_type = "t3.micro"

  root_block_device {
    volume_size = 20

    # <<<<<<<< TRY CHANGING THIS >>>>>>>>
    # gp3 -> gp2  
    # add: iops = 3000  
    volume_type = "gp3"
  }

  tags = {
    Name = "InfracostSimpleDemo"
  }
}
