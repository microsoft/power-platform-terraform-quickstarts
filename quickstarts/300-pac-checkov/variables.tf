variable "location" {
  description = "The Azure region where the resources in this example should be created"
  type        = string
}

variable "prefix" {
  description = "The prefix which should be used for all resources name"
  default     = "pac"
  type        = string
}

variable "base_name" {
  description = "The base name which should be used for all resources name"
  default     = "pac"
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID of the service principal with on-premise data gateway admin permissions"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of service principal or user at Power Platform"
  type        = string
}
