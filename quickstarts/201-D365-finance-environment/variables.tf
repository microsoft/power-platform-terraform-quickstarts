variable "d365_finance_environment_name" {
  description = "The name of the D365 Finance environment, such as 'd365fin-dev1"
  type        = string
  validation {
    condition     = length(var.d365_finance_environment_name) <= 20
    error_message = "The length of the d365_finance_environment_name property cannot exceed 20 characters for D365 Finance environment deployments."
  }
}
variable "location" {
  description = "The region where the environment will be deployed, such as 'unitedstates'"
  type        = string
}
variable "language_code" {
  description = "The desired Language Code for the environment, such as '1033' (U.S. english)"
  type        = string
}
variable "currency_code" {
  description = "The desired Currency Code for the environment, such as 'USD'"
  type        = string
}
#Options are "Sandbox", "Production", "Trial", "Developer"
variable "environment_type" {
  description = "The type of environment to deploy, such as 'Sandbox'"
  type        = string
  validation {
    condition     = contains(["Sandbox", "Production", "Trial", "Developer"], var.environment_type)
    error_message = "The selected value for environment_type is not in the list of allowed values in variables.tf"
  }
}
variable "domain" {
  description = "The domain of the environment, such as 'd365fin-dev1'"
  type        = string
  validation {
    condition     = length(var.domain) <= 32
    error_message = "The length of the domain property cannot exceed 32 characters for D365 Finance environment deployments."
  }
}
variable "security_group_id" {
  description = "The security group ID for the environment, such as '00000000-0000-0000-0000-000000000000'"
  type        = string
}
