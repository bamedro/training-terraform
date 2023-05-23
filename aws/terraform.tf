## Don't forget to update names below with your own values
# terraform {
#   backend "s3" {
#     bucket         = "tfstate-falkenmaze83"
#     key            = "state/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     kms_key_id     = "alias/tfstate-falkenmaze83-bucket-key"
#     dynamodb_table = "tfstate-falkenmaze83"
#   }
# }

## Declare required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"

      ## Plugin use version constraint syntax
      ## https://developer.hashicorp.com/terraform/language/expressions/version-constraints#version-constraint-syntax
      version = "~> 4"  
    }
  }
}

## Configure the Cloud Provider
provider "aws" {
  region = var.location
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      PlatformCode    = terraform.workspace
      Environment     = var.environment
      Deployer        = "Terraform"
    }
  }
}