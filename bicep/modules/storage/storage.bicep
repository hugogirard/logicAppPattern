param location string
param suffix string

var strSourceName = 'strs${suffix}'
var strDestName = 'strd${suffix}'
var strFunction = 'strf${suffix}'

resource storageAccountFunction 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: strFunction
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  tags: {
    'description': 'Function Storage'
  }
  kind: 'StorageV2'
  properties: {    
    accessTier: 'Hot'
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

resource storageAccountDestination'Microsoft.Storage/storageAccounts@2021-04-01' = {
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
  name: '${storageAccountSource}/default/documents'
  properties: {
    publicAccess: 'None'
  }
}

resource containerDocumentsDestination 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {  
  name: '${storageAccountDestination}/default/documents'
  properties: {
    publicAccess: 'None'
  }
}
