param firewallPrivateIp string = '10.9.0.4'
param spoke1AddressRange string = '10.9.1.0/24'

resource spoke2Route 'Microsoft.Network/routeTables@2021-02-01' = {
  name: 'spoke2-udr'
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'spoke2-udr'
        properties: {
          addressPrefix: spoke1AddressRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}
