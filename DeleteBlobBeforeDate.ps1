<#
AUTHOR:
Manjunath Rao

DESCRIPTION:
This script deletes Azure blobs that are older than X days.
Provide the Azure Storage Account name, access key and container name as input.

#>

## Declaring the variables
$number_of_days_threshold = 15
$current_date = get-date
$date_before_blobs_to_be_deleted = $current_date.AddDays(-$number_of_days_threshold)

# Number of blobs deleted
$blob_count_deleted = 0

# Storage account details
$storage_account_name = "<stg name>" 
$storage_account_key = "<stg key>"
$container = "<container name>"

## Creating Storage context for Source, destination and log storage accounts
$context = New-AzureStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_account_key
$blob_list = Get-AzureStorageBlob -Context $context -Container $container

## Iterate through each blob
foreach($blob_iterator in $blob_list){

    $blob_date = [datetime]$blob_iterator.LastModified.UtcDateTime
    
    # Check if the blob's last modified date is less than the threshold date for deletion
    if($blob_date -le $date_before_blobs_to_be_deleted) {

        # Cmdle to delete the blob
        Remove-AzureStorageBlob -Container $container -Blob $blob_iterator.Name -Context $context

        $blob_count_deleted += 1
    }

}