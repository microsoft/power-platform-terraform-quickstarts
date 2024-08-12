resource "null_resource" "check_and_create_env" {
  count = length(var.users)

  provisioner "local-exec" {
    command = <<EOT
      ./check_and_create_env.ps1 -envName "${var.users[count.index].firstName} ${var.users[count.index].lastName} Dev" -firstName "${var.users[count.index].firstName}" -lastName "${var.users[count.index].lastName}" -domain "${var.domain}"
    EOT
    interpreter = ["pwsh","-Command"]
    
    environment = {
      ENV_NAME = "${var.users[count.index].firstName} ${var.users[count.index].lastName} Dev"
    }
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

locals {
  env_data = [for i in range(length(var.users)) : {
    environment_id = try(null_resource.check_and_create_env[i].triggers.environment_id, "")
    instance_url   = try(null_resource.check_and_create_env[i].triggers.instance_url, "")
  }]
}

output "environment_ids" {
  value = { for i, user in var.users : "${user.firstName} ${user.lastName} Dev" => local.env_data[i].environment_id }
}

output "instance_urls" {
  value = { for i, user in var.users : "${user.firstName} ${user.lastName} Dev" => local.env_data[i].instance_url }
}
