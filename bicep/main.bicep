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
    logicAppSystemAssingedIdentityObjecId: logicapp.outputs.logicAppSystemAssingedIdentityObjecId    
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

module monitoring 'modules/monitoring/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    suffix: suffix
  }
}

module function 'modules/functions/functions.bicep' = {
  name: 'function'
  params: {
    insightCnxString: monitoring.outputs.insightCnxString
    insightKey: monitoring.outputs.insightKey
    location: location
    storageCnxString: storage.outputs.storageLogicAppCnxString
    suffix: suffix
    storageDestCnxString: storage.outputs.storageDestinationCnxString
    storageSourceCnxString: storage.outputs.storageSourceCnxString
  }
}

output functionProcessorName string = function.outputs.functionProcessorName
output functionDispatcherName string = function.outputs.functionDispatcherName
output logicAppName string = logicapp.outputs.logicAppName
