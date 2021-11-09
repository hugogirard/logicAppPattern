param systemIdentityId string
param sourceStorageName string
param sourceStorageId string
param destinationStorageId string

// Storage Blob Data Contributor role Id
var storageBlobDataContributor = '${subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')}'
var uniqueRoleGuidStorageAccount = '${guid(sourceStorageId,storageBlobDataContributor,sourceStorageId)}'
var rbacDataContributorSourceRoleName = '${sourceStorageName}/Microsoft.Authorization/${uniqueRoleGuidStorageAccount}'

resource rbacDataContributorSourceStorage 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: rbacDataContributorSourceRoleName
  properties: {
    principalId: systemIdentityId
    roleDefinitionId: storageBlobDataContributor
    scope: sourceStorageId
    principalType: 'ServicePrincipal'
  }
}
