param location string
param suffix string

var image = 'maildev/maildev'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: 'aci-${suffix}'
  location: location
  properties: {
    containers: [
      {
        name: 'maildev'
        properties: {
          image: image
          ports: [
            {
              port: 1025
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
        }        
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}
