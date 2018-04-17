<#
.DESCRIPTION
This example demonstrates how to create a virtual machine from an image.
.NOTES
1. Before you use this sample, please install the latest version of Azure PowerShell from here: http://go.microsoft.com/?linkid=9811175&clcid=0x409
2. Provide the appropriate values for each variable.
3. 
#>

## Create image from a VHD in a storage account (Unmanaged Disk)
#================================================================#

## Desalocar a VM
Stop-AzureRmVM -ResourceGroupName <resourceGroup> -Name <vmName>

## Generalizar a VM
Set-AzureRmVm -ResourceGroupName <resourceGroup> -Name <vmName> -Generalized

## Verifique o status da VM
$vm = Get-AzureRmVM -ResourceGroupName <resourceGroup> -Name <vmName> -Status
$vm.Statuses

## Criar a imagem
Save-AzureRmVMImage -ResourceGroupName <resourceGroup> -Name <vmName> `
-DestinationContainerName image -VHDNamePrefix <vhdPredix> `
-Path <C:\temp\image.json>

## Create a Virtual Machine from a Image
#======================================#

## Variables
$rgName = <resourceGroup>
$location = "brazilsouth"

## Armazena as configurações da Vnet na variavel $vnet e cria uma interface de rede para a VM
$vnet = Get-AzureRmVirtualNetwork -Name <vnetName> -ResourceGroupName <resourceGroup>
$nicName = <nicname>
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location `
-SubnetId $vnet.Subnets[4].Id 

## Define o nome da VM (visível no portal), hostname, tamanho da VM e nome do disco de SO.
$vmName = <vmName>
$computerName = <computerName>
$vmSize = "Standard_F4"
$osDiskName = $vmName + "osDisk"

# Define as credenciais
$cred = Get-Credential

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

## Adiciona o disco de SO
$imageUri = "https://stgName.blob.core.windows.net/system/Microsoft.Compute/Images/vm001-os.vhd"
$osDiskUri = "https://stgName.blob.core.windows.net/vhds/vm001-osDisk.vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage -SourceImageUri $imageUri -Windows

## Adiciona o disco de Dados
$dataImageUri = "https://stgName.blob.core.windows.net/system/Microsoft.Compute/Images/vvm001-data.vhd"
$dataDiskUri = "https://stgName.blob.core.windows.net/vhds/vm001-dataDisk.vhd"
$vm = Add-AzureRmVMDataDisk -VM $vm -Name "dd1" -VhdUri $dataDiskUri -SourceImageUri $dataImageUri -Lun 0 -CreateOption fromImage

# Comando para criar a VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm -Verbose 
