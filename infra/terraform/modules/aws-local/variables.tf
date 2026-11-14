variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "acdp"
}

variable "environment" {
  description = "Environment name, used in the SSM parameter path."
  type        = string
  default     = "local"
}
