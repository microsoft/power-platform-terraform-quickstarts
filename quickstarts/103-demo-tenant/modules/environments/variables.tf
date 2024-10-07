variable "users" {
  description = "List of user objects with first and last names"
  type        = list(object({
    firstName = string
    lastName  = string
  }))
}

variable "domain" {
  type = string
}

variable "full_module_path" {
  description = "The absolute path to the module"
  type        = string
}