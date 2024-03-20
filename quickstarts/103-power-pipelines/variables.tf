variable "aliases" {
  description = "The aliases to create users for"
  type        = list(string)
  default = [ "test1", "test2" ]
}

variable "app_name" {
  description = "The name of the app to create"
  type        = string 
}

variable "developer_group" {
  description = "The name of the developer group"
  type        = string
}