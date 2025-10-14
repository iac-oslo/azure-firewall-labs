resource udr 'Microsoft.Network/routeTables@2021-02-01' existing = {
  name: 'spoke2-udr'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'vnet-spoke2-westeurope'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: 'subnet-workload'
  parent: vnet
  properties: {
    addressPrefixes: [
      '10.9.2.0/24'
    ]
    routeTable: {
      id: udr.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
