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

# Automatically get the latest Amazon Linux 2023 AMI
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

# ------------------------------
# EC2 INSTANCE (Cost Impact Demo)
# ------------------------------
resource "aws_instance" "my_web_app" {
  ami = data.aws_ami.al2023.id

  # <<<<<<<< COST DEMO >>>>>>>>
  # Try changing:
  #   t3.micro -> t3.large
  #   t3.micro -> m5.xlarge
  #   t3.micro -> m5.2xlarge
  #
  # InfraCost will show huge differences.
  instance_type = "t3.micro"

  tags = {
    Environment = "production"
    Service     = "web-app"
  }

  root_block_device {
    volume_size = 20

    # <<<<<<<< COST DEMO >>>>>>>>
    # Try changing:
    #   gp3 -> gp2
    #
    # Try adding:
    #   iops = 3000
    #
    # InfraCost models EBS performance cost changes perfectly.
    volume_type = "gp3"
  }
}

# ------------------------------
# S3 BUCKET
# ------------------------------
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "infracost-demo-${random_id.suffix.hex}"
}

# ------------------------------
# S3 OBJECT WITH CHANGEABLE STORAGE CLASS
# ------------------------------
resource "aws_s3_bucket_object" "sample_object" {
  bucket = aws_s3_bucket.demo_bucket.id
  key    = "example.txt"
  source = "example.txt"

  # <<<<<<<< COST DEMO >>>>>>>>
  # Try changing:
  #   STANDARD       -> STANDARD_IA
  #   STANDARD_IA    -> ONEZONE_IA
  #   ONEZONE_IA     -> GLACIER
  #   GLACIER        -> GLACIER_IR
  #
  # InfraCost will instantly show storage + retrieval cost changes.
  storage_class = "STANDARD"
}
