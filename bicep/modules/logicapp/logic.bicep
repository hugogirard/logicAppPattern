param location string
param suffix string

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
      use32BitWorkerProcess: true
    }
    serverFarmId: webFarm.id
    clientAffinityEnabled: false    
  }
}

output logicAppSystemAssingedIdentityObjecId string = logiapp.identity.principalId
output logicAppName string = logiapp.name
