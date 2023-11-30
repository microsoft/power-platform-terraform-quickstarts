
# variable "subscription_id" {
#   description = "The Azure subscription ID to use"
#   type        = string
# }

# variable "tenant_id" {
#   description = "The Azure tenant ID to use"
#   type        = string
# }

# variable "aliases" {
#   description = "The aliases to create users for"
#   type        = list(string)
# }

variable "billing_policy_resource_group" {
  description = "The resource group for the billing policy"
  type        = string
}

variable "billing_policy_subscription_id" {
  description = "The subscription id for the billing policy"
  type        = string
}