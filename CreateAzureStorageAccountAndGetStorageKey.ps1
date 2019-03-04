
<#

.DESCRIPTION

This sample demonstrates how to create an Azure Storage Account and get the storage key.

.NOTES

1. Before you use this sample, please install the latest version of Azure PowerShell from here: http://go.microsoft.com/?linkid=9811175&clcid=0x409
2. Provide the appropriate values for each variable.

#>

# Autenticação
Login-AzureRmAccount

# Seleciona a assinatura
Select-AzureRmSubscription -Subscription "Nome da Assinatura"

#Variaveis
$location = "Brazil South"
$resourceGroup = "GRPRD-CLIENTE-TCB-01"
$storageAccountName = "stgtcbcliente01"

# Criar grupo de recursos
New-AzureRmResourceGroup $resourceGroup -Location $location

# Cria conta de armazenamento
# Verifica disponibilidade do nome escolhido
Get-AzureRmStorageAccountNameAvailability $storageAccountName

# Registra o provedor, caso nao esteja registrado
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Storage

# Cria conta de armazenamento
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
-Name $storageAccountName -SkuName "Standard_LRS" -AccessTier Cool -Kind StorageV2 -Location $location

# Cria Container para armazenar os backups
Set-AzureRmCurrentStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$ContainerName = "backups"
New-AzureStorageContainer -Name $ContainerName -Permission Off

Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $storageAccountName

$StorageKey = ((Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccountName)| Where-Object {$_.KeyName -eq 'key1'}).Value
clear
echo "Nome da Conta de Armazenamento: $storageAccountName" 
echo "Chave: $StorageKey"
