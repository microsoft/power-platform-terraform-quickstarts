variable "storage_container_name" {
  description = "The name of the AI Search service storage container"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the AI Search storage account"
  type        = string
}  

variable "search_endpoint_uri" {
  description = "The AI Search endpoint URI"
  type        = string
}

variable "search_api_key" {
  description = "The API key for the Azure AI Search service"
  type        = string
}

variable "search_datasource_name" {
  description = "The name of the AI Search service datasource"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the AI Search storage account"
  type = string
}

variable "storage_account_key" {
  description = "The primary key of the AI Search storage account"
  type = string
}