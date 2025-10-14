targetScope = 'resourceGroup'

param parLocation string
param parAddressRange string

var varVNetName = 'vnet-hub-${parLocation}'

module modVNet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'deploy-${varVNetName}'
  params: {
    addressPrefixes: [
      parAddressRange
    ]
    name: varVNetName
    location: parLocation
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 0)]
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 1)]
      }
      {
        name: 'subnet-workload'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 2)] 
      }
      {
        name: 'AzureFirewallManagementSubnet'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 3)] 
      }
    ]
    enableTelemetry: false
  }
}

output hubVnetId string = modVNet.outputs.resourceId
output workloadSubnetResourceId string = modVNet.outputs.subnetResourceIds[2]
