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

variable "environment_display_name" {
  description = "Power Platform environment display name"
  type        = string
  default = "Copilot Quickstart"
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

variable "copilot_name" {
  description = "Name of the Copilot"
  type        = string
}

variable "connection_display_name" {
  description = "Display name of the connection"
  type        = string
  default = "Copilot Quickstart Connection"
}

variable "environment_access_group_id" {
  description = "The id of the environment Entra security access group"
  type        = string
}

variable "oai_resource_name" {
  description = "The name of the deployed OpenAI resource"
  type = string
}

variable "oai_api_key" {
  description = "The API key for the deployed OpenAI resource"
  type = string
}

variable "search_endpoint_uri" {
  description = "The search endpoint URL for the deployed OpenAI resource"
  type = string
}

variable "search_api_key" {
  description = "The search API key for the deployed OpenAI resource"
  type = string
}

variable "admin_id" {
  description = "The object ID of the admin user"
  type        = string
}