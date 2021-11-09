param systemIdentityId string
param sourceStorageName string
param destinationStorageId string
param roleName string = newGuid()

// Storage Blob Data Contributor role Id
var storageBlobDataContributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource stgSource 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: sourceStorageName
}

resource rbacDataContributorSourceStorage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleName
  properties: {
    principalId: systemIdentityId
    roleDefinitionId: storageBlobDataContributor
    principalType: 'ServicePrincipal'
  }
  scope: stgSource
}
