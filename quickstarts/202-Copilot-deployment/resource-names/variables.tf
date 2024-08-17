variable "base-naming-prefix" {
  description = "The base naming prefix for all resources"
  type        = list(string)
  default     = ["copilot-quickstart"]
}

variable "random-length" {
  description = "The length of the random string to append to the resource names"
  type        = number
  default     = 5
}