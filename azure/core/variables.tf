## General Configuration
variable "tenant_id" {
  description = "Azure Tenant ID (i.e. AAD instance) to use. You can get it running 'az account list --output table' with Azure CLI"
  default     = "01234567-89ab-cdef-0123-456789abcdef"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription to use for the deployment. You can get it running 'az account list --output table' with Azure CLI"
  default     = "01234567-89ab-cdef-0123-456789abcdef"
  type        = string
}

variable "environment" {
  description = "Environment purpose (eg. testing, production, etc.)"
  default     = "test"
  type        = string
}

variable "platform_code" {
  description = "Short code and unique ID to identify the platform, often used in urls. Format: 10 letters code"
  default     = "xxxprjprod"
  type        = string
}

variable "location" {
  description = "Location where the resources have to be deployed"
  default     = "northeurope"
  type        = string
}

variable "storage_replication_type" {
  description = "Which level of redundancy we want to apply on storages. Tolerant to node failure within a datacenter: LRS (Locally Redundant Storage), Tolerant to a whole datacenter failure: ZRS (Zone Redundant Storage), Tolerant to a region failure: GRS (Geo-Redundant Storage)"
  default     = "LRS"
  type        = string
}

variable "backup_retention_days" {
  description = "Retention days for fileshare backups"
  default     = 15
  type        = number
}

variable "daily_backup_time" {
  description = "Schedule time for fileshares daily backups"
  default     = "23:00"
  type        = string
}

variable "fileshares" {
  description = "Set of file shares which are backuped up with Azure Recovery Service"
  default     = ["files"]
  type        = set(string)
}