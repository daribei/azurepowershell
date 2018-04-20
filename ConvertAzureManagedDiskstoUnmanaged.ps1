
<#

.DESCRIPTION

This sample demonstrates how to convert Azure Managed Disks to Unmanaged using Azure PowerShell.

.NOTES

1. Before you use this sample, please install the latest version of Azure PowerShell from here: http://go.microsoft.com/?linkid=9811175&clcid=0x409
2. Provide the appropriate values for each variable.

#>

# Variables

$rgName = "rgName"
$vmName = "vmName"

$stgName = "stgName"
$stgKey = "stgKey"

# Part 1 - Copying disks to a Storage Account

$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName
$diskSO = $vm.StorageProfile.OsDisk | Where-Object {$_.ManagedDisk -ne $null} | Select-Object Name
$diskData = $vm.StorageProfile.DataDisks | Where-Object {$_.ManagedDisk -ne $null} | Select-Object Name

$context = New-AzureStorageContext -StorageAccountName $stgName -StorageAccountKey $stgKey

$sas = Grant-AzureRmDiskAccess -ResourceGroupName $rgName -DiskName $diskSO -Access Read -DurationInSecond (60*60*24)
$blobcopyresult = Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestinationContainer "vhds" -DestinationBlob "vmName-diskSO.vhd" -DestinationContext $context

$sas2 = Grant-AzureRmDiskAccess -ResourceGroupName $rgName -DiskName $diskData -Access Read -DurationInSecond (60*60*24)
$blobcopyresult2 = Start-AzureStorageBlobCopy -AbsoluteUri $sas2.AccessSAS -DestinationContainer "vhds" -DestinationBlob "vmName-diskData01.vhd" -DestinationContext $context

# You can retrieve the status using the following command
$blobcopyresult | Get-AzureStorageBlobCopyState
$blobcopyresult2 | Get-AzureStorageBlobCopyState

# Part 2 - Creating the Virtual Machine
$vmconfig = New-AzureRmVMConfig -VMName "newVmName" -VMSize "vmSize"
$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id (Get-AzureRmNetworkInterface -Name "newNicName" -ResourceGroupName $rgName).Id
$vm = Set-AzureRmVMBootDiagnostics -VM $vm -Enable -ResourceGroupName $rgName -StorageAccountName "stgDiagName"

$osDiskUri = "https://stgName.blob.core.windows.net/vhds/vmName-diskSO.vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name "osdisk" -VhdUri $osDiskUri -CreateOption Attach -Windows

$dataDiskUri = "https://stgName.blob.core.windows.net/vhds/vmName-diskData01.vhd"
$vm = Add-AzureRmVMDataDisk -VM $vm -Name "dataDisk1" -VhdUri $dataDiskUri -Lun 0 -CreateOption Attach

New-AzureRmVM -ResourceGroupName $rgName -Location brazilsouth -VM $vm -Verbose
