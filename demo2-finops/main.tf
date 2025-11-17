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

  default_tags {
    tags = {
      Owner       = "Avichay"
      CostCenter  = "RnD"
      Environment = "Demo"
    }
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
  validation {
    condition     = contains(["t3.micro","t3.small","t4g.micro"], var.instance_type)
    error_message = "Use only cost-efficient burstable instances!"
  }
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

resource "random_id" "suffix" { byte_length = 4 }

resource "aws_instance" "finops_instance" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  tags = { Project = "FinOpsDemo" }
}

resource "aws_s3_bucket" "finops_bucket" {
  bucket = "finops-${random_id.suffix.hex}"
  tags   = { Project = "FinOpsDemo" }
}

resource "aws_budgets_budget" "demo_budget" {
  name         = "FinOpsDemoBudget"
  budget_type  = "COST"
  limit_amount = "10"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["you@example.com"]
  }
}

output "budget_name"  { value = aws_budgets_budget.demo_budget.name }
output "instance_id"  { value = aws_instance.finops_instance.id }
