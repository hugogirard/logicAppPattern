param webAppName string
param azureDataFactoryConnectionUrl string
param azureDataFactoryName string
param appInsightKey string
param appInsightCnxString string
param strCnxString string
param location string

resource webApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: webAppName
}

resource appsettings 'Microsoft.Web/sites/config@2021-02-01' = {  
  parent: webApp  
  name: 'appsettings'
  properties: {
      'DATA_FACTORY_CONNECTION_URL': azureDataFactoryConnectionUrl
      'APP_KIND': 'workflowApp'
      'AzureFunctionsJobHost__extensionBundle__id': 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
      'AzureFunctionsJobHost__extensionBundle__version': '[1.*, 2.0.0)'
      'FUNCTIONS_EXTENSION_VERSION': '~3'
      'FUNCTIONS_WORKER_RUNTIME': 'node'
      'FUNCTIONS_V2_COMPATIBILITY_MODE': 'true'
      'WEBSITE_NODE_DEFAULT_VERSION': '~12'
      'APPINSIGHTS_INSTRUMENTATIONKEY': appInsightKey
      'APPLICATIONINSIGHTS_CONNECTION_STRING': appInsightCnxString
      'AzureWebJobsStorage': strCnxString
      'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING': strCnxString
      'WEBSITE_CONTENTSHARE': 'logicapp98'
      'WORKFLOWS_SUBSCRIPTION_ID': subscription().subscriptionId
      'WORKFLOWS_RESOURCE_GROUP_NAME': resourceGroup().name
      'AZURE_DATA_FACTORY_NAME': azureDataFactoryName
      'WORKFLOWS_LOCATION_NAME': location
  }
}
