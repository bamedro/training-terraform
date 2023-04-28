## General Configuration
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
  default     = "eu-west-1"
  type        = string
}
