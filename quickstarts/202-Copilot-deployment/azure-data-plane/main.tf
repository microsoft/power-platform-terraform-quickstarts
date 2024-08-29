terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.7.0-preview"
    }
    # restful = {
    #   source = "magodo/restful"
    #   version = ">=0.16.1"
    # }
  }
}

# provider "restful" {
#   base_url = var.search_endpoint_uri
#   security = {}
# }

provider "powerplatform" {
  use_cli = true
}

locals {
    datasource_json = {
        type        = "azureblob"
        credentials = {
            connectionString = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_key};EndpointSuffix=core.windows.net" 
        }
        container = {
          name = var.storage_container_name
        } 
        name = var.search_datasource_name
    }
    # This is a basic sample index, it should be customized to the relevant scenario.
    index_json = {
        name = "copilot-quickstart-ai-search-index",
         "fields": [
          {
            "name": "id",
            "type": "Edm.String",
            "key": true,
            "searchable": false,
            "filterable": false,
            "sortable": true,
            "facetable": false
          },
          {
            "name": "title",
            "type": "Edm.String",
            "searchable": true,
            "filterable": false,
            "sortable": true,
            "facetable": false
          },
          {
            "name": "description",
            "type": "Edm.String",
            "searchable": true,
            "filterable": false,
            "sortable": false,
            "facetable": false
          }
         ]
    }
    # This is a basic sample indexer, it should be customized to the relevant scenario.
    indexer_json = {
      name            = "copilot-quickstart-ai-search-indexer"
      dataSourceName  = local.datasource_json.name
      targetIndexName = local.index_json.name
      # Maps metadata_storage_name (a default value from blob datasources) to the title field in the index.
      fieldMappings = [
        {
          sourceFieldName = "metadata_storage_name"
          targetFieldName = "title"
        }
      ]
    }
    scope = "https://search.azure.com/.default"
}

#---- 1 - Set up storage on the AI Search resource ----

resource "powerplatform_rest" "search_datasource" {
  create = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/datasources?api-version=2023-11-01"
    method = "POST"
    expected_http_status = [201]
    body = jsonencode(local.datasource_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
  update = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/datasources/${local.datasource_json.name}?api-version=2023-11-01"
    method = "PUT"
    expected_http_status = [201]
    body = jsonencode(local.datasource_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
  destroy = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/datasources/${local.datasource_json.name}?api-version=2023-11-01"
    method = "DELETE"
    expected_http_status = [204]
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
}

# #---- 2 - Set up the index on the AI Search resource ----

resource "powerplatform_rest" "search_index" {
  create = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/indexes?api-version=2023-11-01"
    method = "POST"
    expected_http_status = [201]
    body = jsonencode(local.index_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
  update = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/indexes/${local.index_json.name}?api-version=2023-11-01"
    method = "PUT"
    expected_http_status = [201]
    body = jsonencode(local.index_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
  destroy = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/indexes/${local.index_json.name}?api-version=2023-11-01"
    method = "DELETE"
    expected_http_status = [201]
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
}

# #---- 3 - Set up the indexer on the AI Search resource ----

resource "powerplatform_rest" "search_indexer" {
  create = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/indexers?api-version=2023-11-01"
    method = "POST"
    expected_http_status = [201]
    body = jsonencode(local.indexer_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
  update = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/indexers/${local.index_json.name}?api-version=2023-11-01"
    method = "PUT"
    expected_http_status = [201]
    body = jsonencode(local.indexer_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
  destroy = {
    scope = local.scope
    url = "${var.search_endpoint_uri}/indexers/${local.index_json.name}?api-version=2023-11-01"
    method = "DELETE"
    expected_http_status = [201]
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
}