variable "platform_code" {
  description = "Short code and unique ID to identify the platform, often used in urls. Format: 10 letters code"
  default     = "xxxprjprod"
  type        = string
}

variable "location" {
  description = "Location where the resources have to be deployed"
  default     = "francecentral"
  type        = string
}

variable "resource_group" {
  description = "Name of the Resource Group where the resources have to be deployed"
  default     = "xxxprj-rg"
  type        = string
}

variable "cidr_block" {
    description = "CIDR Block for the VPC (e.g., 10.0.0.0/16)"
    type = string
    default =  "10.0.0.0/16"
    validation {
        condition = can(cidrnetmask(var.cidr_block))
        error_message = "Must be a valid CIDR block"
    }
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  default     = {
    Deployer        = "Terraform"
  }
  type        = map(string)
}