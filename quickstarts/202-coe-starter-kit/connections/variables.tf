variable "parameters" {
  type        = object({
    release = object({
      build_from_source = bool,
      connections_exist = bool,
      source_branches = string,
      environment_id = string
    })
  })
}