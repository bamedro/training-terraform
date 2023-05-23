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

variable "storage_replication_type" {
  description = "Which level of redundancy we want to apply on storages. Tolerant to node failure within a datacenter: LRS (Locally Redundant Storage), Tolerant to a whole datacenter failure: ZRS (Zone Redundant Storage), Tolerant to a region failure: GRS (Geo-Redundant Storage)"
  default     = "LRS"
  type        = string
}

variable "resource_group" {
  description = "Name of the Resource Group where the resources have to be deployed"
  default     = "xxxprj-rg"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  default     = {
    Deployer        = "Terraform"
  }
  type        = map(string)
}