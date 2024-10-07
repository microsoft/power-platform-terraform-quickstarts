output "user_environment_ids" {
  value = { for i, user in var.users : "${user.firstName} ${user.lastName} Dev" => local.env_data[i].environment_id }
}

output "user_instance_urls" {
  value = { for i, user in var.users : "${user.firstName} ${user.lastName} Dev" => local.env_data[i].instance_url }
}
