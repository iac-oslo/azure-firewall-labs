targetScope = 'subscription'
param parLocation string

import { getResourcePrefix, hubAddressRange, adminUsername, adminPassword } from 'variables.bicep'

var resourcePrefix = getResourcePrefix(parLocation)
var resourceGroupName = 'rg-${resourcePrefix}'
module rg 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'deploy-${resourceGroupName}'
  params: {
    name: resourceGroupName
    tags: {
      Environment: 'IaC'
    }
  }
}

module workspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'deploy-law'
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
  params: {
    name: 'law-${resourcePrefix}'
    location: parLocation
  }
}

module hub 'modules/hub.bicep' = {
  name: 'deploy-hub-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
  params: {
    parLocation: parLocation
    parAddressRange: hubAddressRange
  }
}

module modHubVM 'br/public:avm/res/compute/virtual-machine:0.20.0' = {
  name: 'deploy-hub-vm-${parLocation}'
  scope: resourceGroup(resourceGroupName)
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    name: 'vm-hub-${parLocation}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: hub.outputs.workloadSubnetResourceId
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
        storageAccountType: 'Standard_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_B1s'
    availabilityZone: -1
    location: parLocation
    enableTelemetry: false
  }
}

module bastion 'modules/bastion.bicep' = {
  name: 'deploy-bastion-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  params: {
    parLocation: parLocation
    hubVnetId: hub.outputs.hubVnetId
  }
}

module firewall 'modules/firewall.bicep' = {
  name: 'deploy-firewall-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  params: {
    parLocation: parLocation
    hubVnetId: hub.outputs.hubVnetId
  }
}

module spokes 'modules/spoke.bicep' = [for i in range(1, 2): {
  name: 'deploy-spoke${i}-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  params: {
    parIndex: i
    parLocation: parLocation
    parAddressRange: '10.9.${i}.0/24'
    adminUsername: adminUsername
    adminPassword: adminPassword
    hubVnetId: hub.outputs.hubVnetId
  }  
}]

