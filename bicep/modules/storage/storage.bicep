param location string
param suffix string

var strSourceName = 'strs${suffix}'
var strDestName = 'strd${suffix}'
var strLogicApp = 'strl${suffix}'

resource storageAccountLogicApp 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: strLogicApp
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  tags: {
    'description': 'Logic App Storage and Function'
  }  
  kind: 'StorageV2'
  properties: {    
    accessTier: 'Hot'
  }  
}

resource symbolicname 'Microsoft.Storage/storageAccounts/queueServices/queues@2019-06-01' = {
  name: '${storageAccountLogicApp.name}/default/processed-copy'
  properties: {
    metadata: {}
  }
}


resource storageAccountSource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: strSourceName
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  tags: {
    'description': 'Document Source Storage'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource storageAccountDestination 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: strDestName
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  tags: {
    'description': 'Document Destination Storage'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource containerDocumentsSource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {  
  name: '${storageAccountSource.name}/default/documents'
  properties: {
    publicAccess: 'None'
  }
}

resource containerDocumentsDestination 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {  
  name: '${storageAccountDestination.name}/default/documents'
  properties: {
    publicAccess: 'None'
  }
}


output storageSourceCnxString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountSource.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountSource.id, storageAccountSource.apiVersion).keys[0].value}'
output storageDestinationCnxString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountDestination.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountDestination.id, storageAccountDestination.apiVersion).keys[0].value}'
output storageLogicAppCnxString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountLogicApp.id, storageAccountLogicApp.apiVersion).keys[0].value}'
