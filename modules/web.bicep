// NOTE: you do NOT have to edit this file unless you wish to do custom configurations

@description('Azure region where resources should be deployed')
param location string

@description('unique string appended to each resource name')
var namePostfix = uniqueString(resourceGroup().id)

@description('A storage account to host the website')
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'web${namePostfix}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

@description('Web endpoint where https:// and trailing slash is removed')
var origin = replace(replace(storage.properties.primaryEndpoints.web, 'https://', ''), '/', '')

@description('CDN profile resource and CDN endpoint child resource')
resource cdn 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: 'cdnprofile${namePostfix}'
  location: location
  sku: {
    name: 'Standard_Microsoft'
  }

  resource endpoint 'endpoints' = {
    name: 'cdnendpoint${namePostfix}'
    location: location
    properties: {
      originHostHeader: origin
      isHttpAllowed: false
      origins: [
        {
          name: 'storageOrigin'
          properties: {
            hostName: origin
          }
        }
      ]
    }
  }
}

var storageWebEndpoint = storage.properties.primaryEndpoints.web
var urlMinusTrailingSlash = take(storageWebEndpoint, length(storageWebEndpoint) - 1)

@description('The web endpoint with the trailing slash removed (for CORS)')
output storageWebEndpoint string = urlMinusTrailingSlash

@description('CDN endpoint URL (for CORS)')
output cdnEndpoint string = 'https://${cdn::endpoint.properties.hostName}'
