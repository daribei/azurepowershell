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