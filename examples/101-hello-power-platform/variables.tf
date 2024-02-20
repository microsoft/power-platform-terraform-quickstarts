variable "aliases" {
  description = "The aliases to create users for"
  type        = list(string)
  default = [ "test1", "test2" ]
}