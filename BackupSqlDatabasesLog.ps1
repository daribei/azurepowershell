<#
.DESCRIPTION
This sample demonstrates how to create a Virtual Machine with Azure PowerShell. 
.NOTES
1. Before you use this sample, please provide the appropriate values for each variable;
2. Install SQLServer Module -> Install-Module -Name SQLServer
3 Create a SQL Server credential -> https://bit.ly/2r6mkfl
#>

Import-Module sqlserver -Force
# set the parameter values  
$storageAccount = "<stg name>"
$blobContainer = "<container name>"  
$backupUrlContainer = "https://<stg name>.blob.core.windows.net/$blobContainer/"
$credentialName = "<credential name>"  
$filename = (get-date).tostring("yyyyMMdd_HHmmss") + ".trn"
                            
$path = "SQLSERVER:\SQL\<host name>\default\databases"   
$alldatabases = get-childitem -Force -path $path |Where-object {$_.name -ne "tempdb"}

    foreach ($db in $alldatabases)
    {
        $nmBackup = $backupUrlContainer + "backup_"+$db.Name+"_$filename"
        $recoverymodel = $db.RecoveryModel

           if ($recoverymodel -eq "Full"){
                Backup-SqlDatabase -serverInstance "<host name>" -Database $db.Name -BackupFile $nmBackup -SqlCredential $credentialName -BackupAction Log  -CompressionOption On
           }
    }