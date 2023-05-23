## Don't forget to update names below with your own values
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "votrenom1234-core-config"
#     storage_account_name = "votrenom1234"
#     container_name       = "tfstates"
#     key                  = "core.votrenom1234.terraform.tfstate"
#   }
# }

## Declare required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"

      ## Plugin use version constraint syntax
      ## https://developer.hashicorp.com/terraform/language/expressions/version-constraints#version-constraint-syntax
      version = "=3.9.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
