param location string = resourceGroup().location
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'test${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }

  resource blobService 'blobServices' = {
    name: 'default'

    resource container 'containers' = {
      name: 'images'
      properties: {
        publicAccess: 'Blob'
      }
    }
  }
}

resource otherContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: storageAccount::blobService
  name: 'thumbnails'
  properties: {
    publicAccess: 'Blob'
  }
}

output storageAccountName string = storageAccount.name
output webEndpoint string = storageAccount.properties.primaryEndpoints.web
#disable-next-line outputs-should-not-contain-secrets
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
