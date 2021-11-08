@description('The location where the azure resources will be deployed')
param location string

var suffix = uniqueString(resourceGroup().id)


module storage 'modules/storage/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    suffix: suffix
  }
}

module dataFactory 'modules/dataFactory/factory.bicep' = {
  name: 'datafactory'
  params: {
    location: location
    suffix: suffix
  }
}
