@description('Azure region where resources should be deployed')
param location string = 'westeurope'

@description('A serverless Cosmos DB account')
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: 'cosmos-account-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-11-15' = {
  name: cosmosAccount.name
  properties: {
    resource: {
      id: 'azure101'
    }
  }

  resource container 'containers@2022-11-15' = {
    name: 'images'
    properties: {
      resource: {
        id: database.id
        partitionKey: {
          kind: 'Hash'
          paths: [
            'images/${database.id}'
          ]
        }
      }
    }
  }
}

#disable-next-line outputs-should-not-contain-secrets
output connectionString array = cosmosAccount.listConnectionStrings().connectionStrings

// TODO: add a resource of type Microsoft.DocumentDB/databaseAccounts/sqlDatabases
//       - make the resource a nested child resource of the cosmos db account resource
//       - give the database the exact name that your function app expects (check your cosmos db input/output bindings)

// TODO: add a resource of type Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers
//       - make the resource a nested child resource of the sqlDatabases resource (i.e. Account > Database > Container)
//       - make sure to give the container the name that your function app expects (check your cosmos db input/output bindings)
//       - configure the "partitionKey" property (properties.resource.partitionKey) to match what your function app expects (again, check bindings)

// TODO: add an output for the connection string of the Cosmos DB _account_ resource
//       - hint: use the listConnectionStrings() method on the account resource
//         sample response from listConnectionStrings:
//          {
//            "connectionStrings": [
//              {
//                "connectionString": "connection-string",
//                "description": "Name of the connection string"
//              }
//            ]
//          } 
