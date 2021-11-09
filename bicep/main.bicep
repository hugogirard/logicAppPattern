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
