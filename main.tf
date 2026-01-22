terraform {
  # Require Terraform version 1.6 or higher
  required_version = ">= 1.6"

  # Backend configuration for remote state storage
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}
