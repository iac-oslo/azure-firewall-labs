param parLocation string = 'westeurope'

resource firewallPolicies 'Microsoft.Network/firewallPolicies@2024-07-01' existing = {
  name: 'nfp-${parLocation}'
}

var spokeIPs = [
      '10.9.2.0/24'
      '10.9.1.0/24'
    ]

resource spokesRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  parent: firewallPolicies
  name: 'SpokesFirewallNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'spokes-net-rc01'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
        {
            name: 'allow-ICMP-between-spokes'
            ruleType: 'NetworkRule'
            description: 'Allow ping between spokes'
            sourceAddresses: spokeIPs
            ipProtocols: [
              'ICMP'
            ]
            destinationPorts: [
                '*'
            ]
            destinationAddresses: spokeIPs
          }          
        ]
      }                      
    ]
  }
}
