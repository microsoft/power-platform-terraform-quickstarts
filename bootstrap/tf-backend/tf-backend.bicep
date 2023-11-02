targetScope = 'resourceGroup'
param location string = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'tfstate${uniqueString(subscription().subscriptionId)}'
  location: location
  sku: {
      name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
      accessTier: 'Hot'
      encryption: {
          keySource: 'Microsoft.Storage'
          services: {
              blob: {
                  enabled: true
              }
          }
      }
  }
}

resource bs 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: 'default'
  parent: sa
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: bs
  name: 'tfstate'
  properties: {
      publicAccess: 'None'
  }
}

resource lock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'rg-delete-lock'
  properties: {
      level: 'CanNotDelete'
  }
  scope: resourceGroup()
}

resource saLock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'sa-delete-lock'
  properties: {
      level: 'CanNotDelete'
  }
  scope: sa
}

output storage_account_name string = sa.name
output container_name string = container.name
