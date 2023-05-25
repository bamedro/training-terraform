## Don't forget to update names below with your own values
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "briandev-core-rg"
#     storage_account_name = "briandev4tfbackend"
#     container_name       = "tfstates"
#     key                  = "core.briandev.terraform.tfstate"
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

## Configure the Microsoft Azure Provider
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}
