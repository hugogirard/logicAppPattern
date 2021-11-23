param webAppName string
param azureDataFactoryConnectionUrl string

resource webApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: webAppName
}

resource appsettings 'Microsoft.Web/sites/config@2021-02-01' = {  
  parent: webApp  
  name: 'appsettings'
  properties: {
      'DATA_FACTORY_CONNECTION_URL': azureDataFactoryConnectionUrl
  }
}
