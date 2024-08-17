variable "azure_location" {
  description = "Azure resources location"
  type        = string
  default     = "East US"
}

variable "openai_environment" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "copilot_name" {
  description = "Name of the Copilot deployment"
  type        = string
  default     = "chat_model_gpt_4o_2024_05_13"
}

variable "resource_group" {
  description = "The name of the resource group"
  type        = string
}

variable "ai_search"  {
  description = "The name of the AI Search service"
  type        = string
}

variable "data_storage" {
  description = "The name of the storage account"
  type        = string
}

variable "data_container" {
  description = "The name of the storage container"
  type        = string
}