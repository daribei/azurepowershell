<#
    .DESCRIPTION
        A runbook which stop the virtual machine named $vmName and remove this VM from the Load Balancer using the Run As Account (Service Principal).

    .NOTES
        AUTHOR: Daniel Ribeiro
        Website: http://xdanielribeiro.com.br
#>

# Virtual Machine Variables
$rgName = "Resource Group Name"
$vmName = "Virtual Machine Name"
$vmNicname = "NIC Name"
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

# Stop VM
Write-Output "Stoping: $($vmName)"
Stop-AzureRMVM -Name $vmName -ResourceGroupName $rgName -Force

#Remove NIC from NLB
$nic = Get-AzureRmNetworkInterface -Name $vmNicname -ResourceGroupName $rgName
$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $null
Set-AzureRmNetworkInterface -NetworkInterface $nic