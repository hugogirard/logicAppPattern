param location string
param suffix string
param insightCnxString string
param insightKey string
param storageCnxString string

param storageSourceCnxString string
param storageDestCnxString string

var functioNName = ''

var functionKey = listkeys(resourceId('Microsoft.Web/sites/functions',fnProcessor.name,''),fnProcessor.apiVersion).default

resource processorPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'plan-processor-${suffix}'
  location: location
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
}

resource fnProcessor 'Microsoft.Web/sites@2018-11-01' = {
  name: 'processor-${suffix}'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: processorPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }    
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }                             
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insightKey
        }          
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insightCnxString
        }      
        {
          name: 'AzureWebJobsStorage'
          value: storageCnxString
        }    
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageCnxString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'processorapp092'
        }
        {
          name: 'ConfigurationSettings:SourceStorageCnxString'
          value: storageSourceCnxString
        }
        {
          name: 'ConfigurationSettings:SourceStorageContainer'
          value: 'documents'
        }
        {
          name: 'ConfigurationSettings:TargetStorageCnxString'
          value: storageDestCnxString
        }
        {
          name: 'ConfigurationSettings:TargetStorageContainer'
          value: 'documents'
        }
        {
          name: 'StrOutputQueue'
          value: storageCnxString
        }
      ]
    }
  }
}

output functionProcessorName string = fnProcessor.name
output functionProcessorHostName string = 'https://${fnProcessor.properties.hostNames[0]}'

