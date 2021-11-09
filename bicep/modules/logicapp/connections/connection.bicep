param location string

@secure()
param clientId string
@secure()
param clientSecret string

// https://docs.microsoft.com/en-us/azure/logic-apps/set-up-devops-deployment-single-tenant-azure-logic-apps?tabs=github

resource azureDataFactoryConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azureDataFactorADOConnection'
  location: location
  properties: {
    displayName: 'azureDataFactoryConnector'
    api: {
      id: '/subscriptions/${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/azuredatafactory'
    }
    parameterValues: {
      'token:clientId': clientId
      'token:clientSecret': clientSecret
      'token:TenantId': subscription().tenantId
      'token:grantType': 'client_credentials'      
    }
  }
}
