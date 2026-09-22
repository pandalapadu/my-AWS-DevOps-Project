terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.59.0"
    }
  }

  # remote state storage location
  backend "s3" {
    bucket       = "azdevopsvenkat.site-dev"
    key          = "roboshop-eks.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Enables native S3 state locking (Terraform 1.10+)
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}