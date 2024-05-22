output "user_credentials" {
    value = module.identity.user_credentials
}

output "dev_environment_access_group" {
    value = module.identity.dev_environment_access_group
}

output "test_environment_access_group" {
    value = module.identity.test_environment_access_group
}

output "dev_environment" {
    value = { 
        id =  module.power-platform.dev_environment.id
        url = module.power-platform.dev_environment.url
        version = module.power-platform.dev_environment.version
    }
}

output "test_environment" {
    value = { 
        id =  module.power-platform.test_environment.id
        url = module.power-platform.test_environment.url
        version = module.power-platform.test_environment.version
    }
}

