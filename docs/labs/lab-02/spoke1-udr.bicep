param firewallPrivateIp string

resource spoke1Route 'Microsoft.Network/routeTables@2021-02-01' = {
  name: 'spoke1-udr'
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'spoke1-udr'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}
