@description('The location where the azure resources will be deployed')
param location string

@description('The client ID of the Service Principal')
@secure()
param clientId string

@description('The client secret of the Service Principal')
@secure()
param clientSecret string

var suffix = uniqueString(resourceGroup().id)


module storage 'modules/storage/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    suffix: suffix
  }
}

module logging 'modules/logging/insight.bicep' = {
  name: 'logging'
  params: {
    location: location
    suffix: suffix
  }
}

module logicapp 'modules/logicapp/logic.bicep' = {
  name: 'logicapp'
  params: {
    appInsightCnxString: logging.outputs.appInsightCnxString
    appInsightKey: logging.outputs.appInsightKey
    location: location
    strCnxString: storage.outputs.storageLogicAppCnxString
    suffix: suffix
  }
}

module connections 'modules/logicapp/connections/connection.bicep' = {
  name: 'connections'
  params: {
    clientId: clientId
    clientSecret: clientSecret
    location: location
  }
}

module dataFactory 'modules/dataFactory/factory.bicep' = {
  name: 'datafactory'
  params: {
    location: location
    suffix: suffix
  }
}

module pipeline 'modules/dataFactory/pipeline/copytoblob.bicep' = {
  name: 'pipeline'
  params: {
    azureFactoryName: dataFactory.outputs.dataFactoryName
    storageDestinationCnxString: storage.outputs.storageDestinationCnxString
    storageSouceCnxString: storage.outputs.storageSourceCnxString
  }
}

//output azureDataFactoryEndpointUrl string = connections.outputs.azureDataFactoryEndpointUrl
