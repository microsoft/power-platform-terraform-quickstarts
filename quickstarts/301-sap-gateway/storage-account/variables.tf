variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "opdgw"
  type        = string
}

variable "base_name" {
  description = "The base name which should be used for all resources in this example"
  default     = "AzureSAPIntegration"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the resources in this example should be created"
  type        = string
}

variable "region" {
  description = "The Azure region where the resources in this example should be created"
  type        = string
}
variable "subnet_id" {
  description = "The ID of the subnet where the resources in this example should be created"
  type        = string
}
variable "private_dns_zone_blob_id" {
  description = "The IDs of the private DNS zones which should be used for the private endpoint in this example"
  type        = list(string)

}