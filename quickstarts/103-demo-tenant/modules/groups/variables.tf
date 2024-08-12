# Variable for the group name
variable "group_name" {
  description = "The display name of the Azure AD group"
  type        = string
}

# Variable for the group description
variable "group_description" {
  description = "The description of the Azure AD group"
  type        = string
}

variable "user_ids" {
  type = list(string)
}
