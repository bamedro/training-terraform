variable "cidr_block" {
    description = "CIDR Block for the VPC (e.g., 10.0.0.0/16)"
    type = string
    default =  "10.0.0.0/16"
    validation {
        condition = can(cidrnetmask(var.cidr_block))
        error_message = "Must be a valid CIDR block"
    }
}
