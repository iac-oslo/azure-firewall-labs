targetScope = 'resourceGroup'

param parLocation string
param parIndex int
param parAddressRange string
param adminUsername string
@secure()
param adminPassword string
param hubVnetId string

var varVNetName = 'vnet-spoke${parIndex}-${parLocation}'

module modVNet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'deploy-${varVNetName}-${parIndex}'
  params: {
    addressPrefixes: [
      parAddressRange
    ]
    name: varVNetName
    location: parLocation
    subnets: [
      {
        addressPrefixes: [parAddressRange]
        name: 'subnet-workload'
      }
    ]
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'hub-to-spoke${parIndex}'
        remoteVirtualNetworkResourceId: hubVnetId
        useRemoteGateways: false
      }
    ]    
    enableTelemetry: false
  }
}

module modVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.20.0' = {
  name: 'deploy-spoke${parIndex}-vm-${parLocation}'
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    name: 'vm-spoke${parIndex}-${parLocation}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: modVNet.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
        enableAcceleratedNetworking: false
      }
    ]
    osDisk: {
      caching: 'ReadWrite'      
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
    }
    extensionCustomScriptConfig: {
      name: 'install-k6'
      settings: {
        fileUris: [
          'https://raw.githubusercontent.com/iac-oslo/azure-firewall-labs/refs/heads/main/iac/scripts/install-k6.sh'
          'https://raw.githubusercontent.com/iac-oslo/azure-firewall-labs/refs/heads/main/iac/scripts/simulate-snat.js'
        ]
        commandToExecute: 'sh install-k6.sh'
      }
    }

    osType: 'Linux'
    vmSize: 'Standard_D2ds_v6'
    availabilityZone: -1
    location: parLocation
    enableTelemetry: false
  }
}

output spokeVNetId string = modVNet.outputs.resourceId
