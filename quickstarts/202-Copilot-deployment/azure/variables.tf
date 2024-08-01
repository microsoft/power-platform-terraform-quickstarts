variable "azure_location" {
  description = "Azure resources location"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
}