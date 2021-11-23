param location string
param suffix string
param appInsightKey string
param appInsightCnxString string
param strCnxString string

var logicName = 'logic-app-${suffix}'

resource webFarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-${suffix}'
  location: location
  sku: {
    tier: 'WorkflowStandard'
    name: 'WS1'
  }
  kind: 'windows'
}

resource logiapp 'Microsoft.Web/sites@2021-02-01' = {
  name: logicName
  location: location
  kind: 'workflowapp,functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {    
    siteConfig: {
      netFrameworkVersion: 'v4.6'
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }       
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }         
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_V2_COMPATIBILITY_MODE'
          value: 'true'
        }     
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_LOCATION_NAME'
          value: location
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~12'
        }      
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightCnxString
        }
        {
          name: 'AzureWebJobsStorage'
          value: strCnxString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: strCnxString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'logicapp98'
        }
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
          value: resourceGroup().name
        }
        {
          name: 'azuredatafactory-connectionKey'
          value: ''
        }
      ]
      use32BitWorkerProcess: true
    }
    serverFarmId: webFarm.id
    clientAffinityEnabled: false    
  }
}

output logicAppSystemAssingedIdentityObjecId string = logiapp.identity.principalId
output logicAppName string = logiapp.name
