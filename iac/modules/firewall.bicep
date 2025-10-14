targetScope = 'resourceGroup'

param parLocation string
param hubVnetId string

module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.3.1' = {
  name: 'firewallPolicyDeployment'
  params: {
    name: 'nfp-${parLocation}'
    tier: 'Basic'
    threatIntelMode: 'Off'
  }
}

var nafName = 'naf-${parLocation}'
module azureFirewall 'br/public:avm/res/network/azure-firewall:0.8.0' = {
  name: 'deploy-azure-firewall-basic'
  params: {
    name: nafName
    azureSkuTier: 'Basic'
    location: parLocation
    virtualNetworkResourceId: hubVnetId
    firewallPolicyId: firewallPolicy.outputs.resourceId
    publicIPAddressObject: {
      name: 'pip-01-${nafName}'
      publicIPAllocationMethod: 'Static'
      skuName: 'Standard'
      skuTier: 'Regional'
    }    
  }
}

module secondFirewallPublicIP 'br/public:avm/res/network/public-ip-address:0.9.0' = {
  name: 'deploy-second-azfw-public-ip'
  params: {
    name: 'pip-02-${nafName}'
    location: parLocation
    skuName: 'Standard'
    availabilityZones: [1, 2, 3]
  }
}
