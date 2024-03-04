output "user_credentials" {
  value = {
    for idx, user in azuread_user.example :
    user.user_principal_name => {
      user_principal_name = user.user_principal_name
    }
  }
}

output "dev_environment_access_group" {
  value = {
    id = azuread_group.dev_access.id
    name = azuread_group.dev_access.display_name
  }
}

output "test_environment_access_group" {
    value = {
        id = azuread_group.test_access.id
        name = azuread_group.test_access.display_name
    }
}