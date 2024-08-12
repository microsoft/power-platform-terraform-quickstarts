variable "tenant_id" {
  type = string
}

variable "users" {
  type = list(object({
    firstName = string
    lastName  = string
  }))
}

variable "domain" {
  type = string
}
