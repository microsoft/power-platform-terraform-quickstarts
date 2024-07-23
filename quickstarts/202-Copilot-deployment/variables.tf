variable "environment" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name or identifier"
  type        = string
  default     = "Copilot Deployment Quickstart"
}

variable "powerplatform_location" {
  description = "Power Platform environment location"
  type        = string
  default     = "unitedstates"
}

variable "azure_location" {
  description = "Azure resources location"
  type        = string
  default     = "Central US"
}

variable "environment_type" {
  description = "Power Platform environment type"
  type        = string
  default     = "Sandbox"
}

variable "language_code" {
  description = "Language code for the Power Platform environment"
  type        = number
  default     = 1033
}

variable "currency_code" {
  description = "Currency code for the Power Platform environment"
  type        = string
  default     = "USD"
}

variable "environment_access_group_id" {
  description = "The id of the environment Entra security access group"
  type        = string
}