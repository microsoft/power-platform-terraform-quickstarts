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
}

#---- 1 - Set up storage on the AI Search resource ----

resource "powerplatform_rest" "search_datasource" {
  create = {
    scope = "https://search.azure.com/.default"
    url = "${var.search_endpoint_uri}/datasources?api-version=2023-11-01"
    method = "POST"
    expected_http_status = [201]
    body = jsonencode(local.datasource_json)
    headers = [{
      name = "api-key"
      value = var.search_api_key
    }]
  }
}

# resource "restful_operation" "search_datasource" {
#   path = "/datasources"
#   query = {
#     api-version = ["2023-11-01"]
#   }
#   method = "POST"
#   body = jsonencode(local.datasource_json)
# }

# #---- 2 - Set up the index on the AI Search resource ----

# resource "restapi_object" "search_index" {
#   path = "/indexes"
#   query_string = "api-version=2023-11-01"
#   data = jsonencode(local.index_json)
#   id_attribute = "index_response"
# }

# #---- 3 - Set up the indexer on the AI Search resource ----
# # TODO: fix errors on 1 and 2 above so this can continue
# resource "restapi_object" "search_indexer" {
#   depends_on = [restapi_object.search_datasource, restapi_object.search_index]
#   path = "/indexers"
#   query_string = "api-version=2023-11-01"
#   data = jsonencode(local.indexer_json)
#   id_attribute = "indexer_response"
# }

# Tried this approach first but it felt relatively clunky
# resource "powerplatform_rest" "search_indexer" {
#   create = {
#     scope = "${var.dataverse_url}/.default"
#     method = "POST"
#     expected_http_status = [204]
#     body = jsonencode(local.indexer_json)
#     url = "${var.search_endpoint_uri}/indexers@2023-11-01"
#   }
#   destroy = {
#     scope = "${var.dataverse_url}/.default"
#     method = "DELETE"
#     expected_http_status = [204]
#     body = jsonencode(local.indexer_json)
#     url = "${var.search_endpoint_uri}/indexers@2023-11-01"
#   }
# }