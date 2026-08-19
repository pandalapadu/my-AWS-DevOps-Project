terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.48.0"
    }
  }
  backend "s3" {
    bucket       = "azdevopsvenkat.site" # Replace with your unique S3 bucket name
    key          = "providers.tfstate"      # Path inside the bucket where the file will sit
    region       = "us-east-1"           # Your AWS Region
    encrypt      = true                  # Encrypts the state file at rest
    use_lockfile = true                  # Enabiling native state locking file
  }
}
provider "aws" {
  region = "us-east-1"
}