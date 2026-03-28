variable "desired_number_of_availability_zones" {
  default     = 2
  description = "The number of availability zones to create subnets in"
  type        = number
}

variable "namespace" {
  default     = "AlawiDental"
  description = "ID element. Usually an abbreviation of your organization name to help ensure generated IDs are globally unique."
  type        = string
}

variable "ipv4_primary_cidr_block" {
  default     = "10.0.0.0/16"
  description = "The primary IPv4 CIDR block for the VPC"
  type        = string
}

variable "default_tags" {
  default = {
    ManagedBy = "Terraform"
  }
  description = "Key/value pairs for default tags to add to resources"
  type        = map(string)
}
