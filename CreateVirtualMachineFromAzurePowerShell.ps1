
<#

.DESCRIPTION

This sample demonstrates how to create a Virtual Machine with Azure PowerShell. 

.NOTES

1. Before you use this sample, please install the latest version of Azure PowerShell from here: http://go.microsoft.com/?linkid=9811175&clcid=0x409
2. Provide the appropriate values for each variable.

#>

#Provide the subscription Id
$subscriptionId = 'yourSubscriptionId'

#Provide the name of your resource group
$resourceGroupName ='yourResourceGroupName'

#Provide the Azure location (e.g. westus) where VM will be located. 
#Get all the Azure location using command below:
#Get-AzureRmLocation
$location = 'YourLocation'

#Provide the name of the Virtual Machine
$vmName = "NameOfYourVM"

#Log in to Azure
Login-AzureRmAccount

#Set the context to the subscription Id where VM will be created
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

#Create a resource group
New-AzureRmResourceGroup -Name $resourceGroupName -location $location

#Crete user object
$credenciais = Get-Credential -Message "Enter a username and password for the VM"

#Crete a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name "Subnet-Producao" -AddressPrefix 172.16.1.0/24

#create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location `
-Name VNet-DanielRibeiro -AddressPrefix 172.16.0.0/16 -Subnet $subnetConfig

#Create a Public IP
$publicIP = New-AzureRmPublicIpAddress -Name "DrPublicIP" -ResourceGroupName $resourceGroupName `
-Location $location -AllocationMethod Dynamic -DomainNameLabel "danriblab"

#Create a Network Security Group
$nsg = New-AzureRmNetworkSecurityGroup -Name "NSG-DanielRibeiroLab" -ResourceGroupName $resourceGroupName -Location $location

#Create a Rule to RDP Connections
Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
-Name Libera-RDP `
-Description "Libera RDP para internet" `
-Access Allow `
-Protocol Tcp `
-Direction Inbound `
-Priority 100 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 3389

#Save the configurations
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg

#Create a network interface and associate with Public IP and NSG
$nic = New-AzureRmNetworkInterface -Name ($vmName.ToLower()+'_nic') -ResourceGroupName $resourceGroupName -Location $location `
-SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIP.Id -NetworkSecurityGroupId $nsg.Id

#Create a VM configuration
#Get all the Azure VM size using command below:
#Get-AzureRmVmSize -location $location
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_D2_v2_Promo

$vm = Set-AzureRmVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName $vmName `
    -Credential $credenciais
	
$vm = Set-AzureRmVMSourceImage `
    -VM $vm `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$vm = Set-AzureRmVMOSDisk `
    -VM $vm `
    -Name "OSDisk" `
    -DiskSizeInGB 128 `
    -CreateOption FromImage

New-AzureRmVM -VM $vm -ResourceGroupName $resourceGroupName -Location $location
