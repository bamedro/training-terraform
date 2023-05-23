variable "environment" {
  description = "Environment type, such as DEV, TEST or PROD"
  default     = "DEV"
  type        = string
}

variable "location" {
  description = "Location where the resources have to be deployed"
  default     = "francecentral"
  type        = string
}
