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
        id =  module.powerplatform.dev_environment.id
        url = module.powerplatform.dev_environment.url
        version = module.powerplatform.dev_environment.version
    }
}

output "test_environment" {
    value = { 
        id =  module.powerplatform.test_environment.id
        url = module.powerplatform.test_environment.url
        version = module.powerplatform.test_environment.version
    }
}

