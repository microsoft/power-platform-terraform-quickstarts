param location string = 'westus'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: 'terraform-state'
    location: location
}

module tfbackend 'tf-backend.bicep' = {
    name: 'tf-backend'
    scope: rg
    params: {
        location: rg.location
    }
}

resource StorageAccountDefender 'Microsoft.Security/pricings@2023-01-01' = {
    name: 'StorageAccounts'
    properties: {
      pricingTier: 'Standard'
      subPlan: 'DefenderForStorageV2'
      extensions: [
        {
          name: 'OnUploadMalwareScanning'
          isEnabled: 'True'
          additionalExtensionProperties: {
            CapGBPerMonthPerStorageAccount: '-1'
          }
        }
        {
          name: 'SensitiveDataDiscovery'
          isEnabled: 'True'
        }
      ]
    }
  }

output resource_group_name string = rg.name
output storage_account_name string = tfbackend.outputs.storage_account_name
