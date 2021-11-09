param location string
param suffix string

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'log-${suffix}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource insight 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'insight-${suffix}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }  
}

output appInsightKey string = insight.properties.InstrumentationKey
output appInsightCnxString string = insight.properties.ConnectionString
