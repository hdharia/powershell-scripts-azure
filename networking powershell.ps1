Login-AzureRmAccount
Get-AzureRmSubscription
Set-AzureRmContext -SubscriptionName "Harshal Internal Subscription"

New-AzureRmResourceGroup -Name "myNetwork70533" -Location "East US"

#Create Network
New-AzureRmVirtualNetwork -ResourceGroupName "myNetwork70533" -Location "East US" -AddressPrefix 192.168.0.0/16 -Name "vnet1"

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName "myNetwork70533" -Name "vnet1"

#Create Subnet
Add-AzureRmVirtualNetworkSubnetConfig -Name FrontEnd `
-VirtualNetwork $vnet -AddressPrefix 192.168.0.0/24

Add-AzureRmVirtualNetworkSubnetConfig -Name BackEnd `
-VirtualNetwork $vnet -AddressPrefix 192.168.2.0/24

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name http-rule -Description "Allow http" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
-SourceAddressPrefix Internet -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80

$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow http" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
-SourceAddressPrefix Internet -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 22

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName myNetwork70533 -Location "East US" `
-Name "NSG-FrontEnd" -SecurityRules $rule1, $rule2

$nsg

$vnet = Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name FrontEnd `
-AddressPrefix 192.168.0.0/24 -NetworkSecurityGroup $nsg

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

