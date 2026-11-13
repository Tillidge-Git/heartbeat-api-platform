terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "heartbeat-tfstate-109169735495"
    key          = "platform/terraform.tfstate"
    kms_key_id   = "arn:aws:kms:eu-west-2:109169735495:key/7b78d188-9b4b-4cff-9498-a899b6ab7c01"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project    = "heartbeat-api-platform"
      ManagedBy  = "terraform"
      Repository = "heartbeat-api-platform"
    }
  }
}