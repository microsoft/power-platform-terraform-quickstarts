output "dev_environment" {
    value = { 
        id =  module.power-platform.dev_environment.id
        url = module.power-platform.dev_environment.dataverse.url
        version = module.power-platform.dev_environment.dataverse.version
    }
}