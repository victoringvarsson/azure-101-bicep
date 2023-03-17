@description('Azure region where resources should be deployed')
param location string = 'westeurope'

@description('Timestamp used to uniquely name each module deployment')
param now string = utcNow()

module web './modules/web.bicep' = {
  name: 'web-module-${now}'
  params: {
    location: location
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage-module-${now}'
}

module cosmos './modules/cosmos.bicep' = {
  name: 'cosmos-module-${now}'
  params: {
    location: location
  }
}

module servicebus './modules/servicebus.bicep' = {
  name: 'servicebus-module-${now}'
  params: {
    location: location
  }
}

module functionApp './modules/function-app.bicep' = {
  name: 'function-app-module-${now}'
  params: {
    location: location

    // a list of endpoints that will be added to the CORS list on the function app
    corsUrls: [
      web.outputs.storageWebEndpoint
      web.outputs.cdnEndpoint
    ]

    // TODO: add application settings that your function app requires
    // - go through the local.settings.json file in your function app project to see which app settings you need
    // - check ./modules/function-app.bicep to see which app settings are provided automatically for you
    appSettings: [
      {
        name: 'victorimagestore_CONNECTION_STRING'
        value: 'DefaultEndpointsProtocol=https;AccountName=victorimagestore;AccountKey=ps8GduCP0v32DpSGjvpV7tDixLVVWkGNskz+I9B1TXEaPXfYZkn0qMJpGgTfJGjZncY4cKH4OuWR+AStChvP/Q==;EndpointSuffix=core.windows.net'
      }
      {
        name: 'victori_servicebus_CONNECTION_STRING'
        value: 'Endpoint=sb://victori.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=RoqZAz62ydXb52rzCO1LuOqTlK/wYCKEt+ASbPjCcPQ='
      }
      {
        name: 'victoricosmosdb_DOCUMENTDB'
        value: 'AccountEndpoint=https://victori-cosmosdb.documents.azure.com:443/;AccountKey=Ud5GfXE6RWLiKP0RfA0QGnGLfM1JUF0ve8vUT7OuuEaDozv3ba1dHvUjkfkppG3wr6axGSg5bSNpACDbtcO5gA==;'
      }
    ]
  }
}
