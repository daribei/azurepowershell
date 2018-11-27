Import-Module sqlserver -Force
# set the parameter values  
$storageAccount = "<stg name>"
$blobContainer = "<container name>"  
$backupUrlContainer = "https://<stg name>.blob.core.windows.net/$blobContainer/"
$credentialName = "<credential name>"  
$filename = (get-date).tostring("yyyyMMdd_HHmmss") + ".bak"
                            
$path = "SQLSERVER:\SQL\<host name>\default\databases"   
$alldatabases = get-childitem -Force -path $path |Where-object {$_.name -ne "tempdb"}

    foreach ($db in $alldatabases)
    {
        $nmBackup = $backupUrlContainer + "backup_"+$db.Name+"_$filename"
        $db.Name
        Backup-SqlDatabase -serverInstance "<Host name>" -Database $db.Name -BackupFile $nmBackup -SqlCredential $credentialName -CompressionOption On
    }