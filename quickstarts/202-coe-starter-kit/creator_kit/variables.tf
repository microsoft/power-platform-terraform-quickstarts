variable "parameters" {
  type        = object({
    release = object({
      creator_kit_get_latest_release   = bool,
      creator_kit_specific_release_tag = string,
    })
  })
}