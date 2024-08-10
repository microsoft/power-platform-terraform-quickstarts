output "dev_environment" {
  value = powerplatform_environment.dev
}

output "dataverse_url" {
  value = powerplatform_environment.dev.dataverse.url
}