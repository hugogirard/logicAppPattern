param location string
param suffix string

var factoryName = 'data-factory-${suffix}'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: factoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

output identityId string = dataFactory.identity.principalId
