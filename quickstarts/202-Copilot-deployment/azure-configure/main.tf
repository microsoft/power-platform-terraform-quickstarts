terraform {
  required_providers {
    restapi = {
      source = "Mastercard/restapi"
      version = ">=1.19.1"
    }
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.7.0-preview"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

provider "restapi" {
  uri                  = var.search_endpoint_uri
  write_returns_object = true
  debug                = true

  headers = {
    "api-key"      = var.search_api_key,
    "Content-Type" = "application/json"
  }

  create_method  = "POST"
  update_method  = "PUT"
  destroy_method = "DELETE"
}

locals {
    datasource_json = {
        name = "copilot-quickstart-ai-search-data-source"
        description = "Azure AI-searchable storage location"
        type        = "azureblob"
        container = {
            name = var.storage_container_name
        }   
        credentials = {
            connectionString = "ResourceId=${var.storage_account_id};" 
        }
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

resource "restapi_object" "search_datasource" {
  path = "/datasources"
  query_string = "api-version=2023-11-01"
  data = jsonencode(local.datasource_json)
  id_attribute = "datasource_response"
}

#---- 2 - Set up the index on the AI Search resource ----

resource "restapi_object" "search_index" {
  path = "/indexes"
  query_string = "api-version=2023-11-01"
  data = jsonencode(local.index_json)
  id_attribute = "index_response"
}

#---- 3 - Set up the indexer on the AI Search resource ----
# TODO: fix errors on 1 and 2 above so this can continue
resource "restapi_object" "search_indexer" {
  depends_on = [restapi_object.search_datasource, restapi_object.search_index]
  path = "/indexers"
  query_string = "api-version=2023-11-01"
  data = jsonencode(local.indexer_json)
  id_attribute = "indexer_response"
}

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