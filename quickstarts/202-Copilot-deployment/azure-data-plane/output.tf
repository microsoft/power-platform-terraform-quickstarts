output "datasource_json" {
    value = jsonencode(local.datasource_json)
}

output "search_endpoint_uri" {
    value = var.search_endpoint_uri
}

