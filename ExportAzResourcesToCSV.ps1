#Export Azure Resources to CSV files with PowerShell

Login-AzAccount

Select-AzSubscription -Subscription <Subscription Name / ID>

$Resources = Get-AzResource
$ResourcesOutput = $Resources | ForEach-Object { 
    [PSCustomObject]@{
        "ResourceName" = $_.Name
        "Resource Group" = $_.ResourceGroupName
        "Resource Type" = $_.ResourceType
        "Location" = $_.Location
    }
}
$ResourcesOutput | export-csv C:\temp\data.csv -delimiter ";" -force -notypeinformation