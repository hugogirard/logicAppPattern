param storageSouceCnxString string
param storageDestinationCnxString string
param azureFactoryName string

var linkedServiceSourceName = 'AzureStorageSourceLinkedService'
var linkedServiceDestinationName = 'AzureStorageDestinationLinkedService'
var dataSetSource = 'AzureStorageBlobSourceDataset'
var dataSetDestination = 'AzureStorageBlobDestinationDataset'

resource linkedServiceSource 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${azureFactoryName}/${linkedServiceSourceName}'
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: storageSouceCnxString
    }
  }
}

resource linkedServiceDestination 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: '${azureFactoryName}/${linkedServiceDestinationName}'
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: storageDestinationCnxString
    }
  }
}

resource datasetSource 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${azureFactoryName}/${dataSetSource}'
  dependsOn: [
    linkedServiceSource
  ]
  properties: {
    linkedServiceName: {
      referenceName: linkedServiceSourceName
      type: 'LinkedServiceReference'
    }
    parameters: {
      filename: {
        type: 'String'
      }
    }
    annotations: []    
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        fileName: {
          value: '@dataset().filename'
          type: 'Expression'
        }
        container: 'documents'
      }
    }
  }
}

resource datasetDestination 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${azureFactoryName}/${dataSetDestination}'
  dependsOn: [
    linkedServiceDestination
  ]
  properties: {
    linkedServiceName: {
      referenceName: linkedServiceDestinationName
      type: 'LinkedServiceReference'
    }
    annotations: []    
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        fileName: {
          value: '@concat(guid(),\'.txt\')'
          type: 'Expression'
        }
        container: 'documents'
      }
    }
  }
}

resource CopyPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${azureFactoryName}/CopyPipeline'
  properties: {
    activities: [
      {
        name: 'Copy Blob To Blob'
        type: 'Copy'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'BinarySource'
            storeSettings: {
              type: 'AzureBlobStorageReadSettings'
              recursive: true
            }
            formatSettings: {
              type: 'BinaryReadSettings'
            }
          }
          sink: {
            type: 'BinarySink'
            storeSettings: {
              type: 'AzureBlobStorageWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: 'AzureStorageBlobSourceDataset'
            type: 'DatasetReference'
            parameters: {
              filename: {
                value: '@pipeline().parameters.filename'
                type: 'Expression'
              }
            }
          }
        ]
        outputs: [
          {
            referenceName: 'AzureStorageBlobDestinationDataset'
            type: 'DatasetReference'
            parameters: {}
          }
        ]
      }
    ]
    policy: {
      elapsedTimeMetric: {}
      cancelAfter: {}
    }
    parameters: {
      filename: {
        type: 'String'
      }
    }
    annotations: []
  }
  dependsOn: [
    datasetSource
    datasetDestination    
  ]
}
