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

variable "dataverse_url" {
  description = "The URL of the Dataverse environment"
  type        = string
}

variable "search_api_key" {
  description = "The API key for the Azure AI Search service"
  type        = string
}