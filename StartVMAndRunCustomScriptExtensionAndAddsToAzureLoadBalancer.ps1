<#
    .DESCRIPTION
        A runbook which start the virtual machine named $vmName and run a Custom Script Extension stored in the Storage Account named $stgName, 
        and then the script adds this VM to the Azure Load Balancer using the Run As Account (Service Principal).

    .NOTES
        AUTHOR: Daniel Ribeiro
        Website: http://xdanielribeiro.com.br
#>

# Virtual Machine Variables
$rgName = "Resource Group Name"
$vmName = "Virtual Machine Name"
$vmNicname = "NIC Name"
$customScriptExtensionName = "Custom Script Extension Name"

# Storage Account Variables
$stgName = "Storage Account Name"
$stgKey = "Key"
$containerName = "Container Name"
$scriptName = "Script_Name.ps1"
$location = "Brazil South"

# NLB Variables
$nlbName = "Load Balancer Name"
$nlbBackendName = "Backend Pool Name"

#If you used a custom RunAsConnection during the Automation Account setup this will need to reflect that.
$connectionName = "AzureRunAsConnection" 
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Login-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# Start VM
Write-Output "Starting: $($vmName)"
Start-AzureRMVM -Name $vmName -ResourceGroupName $rgName -AsJob

Write-Output "Sleep for 5 minutes"
Start-Sleep -s 300

# Run the script
Set-AzureRMVMCustomScriptExtension –ResourceGroupName $rgName –Location $location -Name $customScriptExtensionName –VMName $vmName `
-StorageAccountName $stgName –StorageAccountKey $stgKey –FileName $scriptName –ContainerName $containerName -ForceRerun $(New-Guid).Guid

#Add NIC (VM) to NLB
$loadbalancer = Get-AzureRmLoadBalancer -Name $nlbName -ResourceGroupName $rgName
$backend = Get-AzureRmLoadBalancerBackendAddressPoolConfig -Name $nlbBackendName -LoadBalancer $loadbalancer
$nic = Get-AzureRmNetworkInterface -Name $vmNicname -ResourceGroupName $rgName
$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $backend
Set-AzureRmNetworkInterface -NetworkInterface $nic