variable "github_repo" {
  type        = string
  default     = "commercial-software-engineering/power-platform-tenant-quickstart"
  description = "The name of the GitHub repository to use for the tenant configuration code."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account to use for storing Terraform state."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to use for storing Terraform state."
}