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

module logicapp 'modules/logicapp/logic.bicep' = {
  name: 'logicapp'
  params: {
    appInsightCnxString: monitoring.outputs.insightCnxString
    appInsightKey: monitoring.outputs.insightKey
    location: location
    strCnxString: storage.outputs.storageLogicAppCnxString
    suffix: suffix
  }
}

module logicAppSettings 'modules/logicapp/settings/settings.bicep' = {
  name: 'logicAppSettings'
  params: {
    azureDataFactoryConnectionUrl: logicapp.outputs.logicAppName
    webAppName: logicapp.outputs.logicAppName    
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
output logicAppName string = logicapp.outputs.logicAppName
output functionProcessorHostName string = function.outputs.functionProcessorHostName
