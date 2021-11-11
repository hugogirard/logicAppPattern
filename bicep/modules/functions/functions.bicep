param location string
param suffix string
param insightCnxString string
param insightKey string
param storageCnxString string

resource processorPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'plan-processor-${suffix}'
  location: location
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
}

resource dispatcherPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'plan-dispatcher-${suffix}'
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
          value: 'node'
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
      ]
    }
  }
}


resource fnDispatcher 'Microsoft.Web/sites@2018-11-01' = {
  name: 'fnDispatcher-${suffix}'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: dispatcherPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
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
      ]
    }
  }
}
