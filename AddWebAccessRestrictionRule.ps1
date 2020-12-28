#Login-AzAccount
Select-AzSubscription -Subscription ""

$rgName = ""
$webApps = ""


$range1 = '13.73.248.16/29,20.36.120.104/29,20.37.64.104/29,20.37.156.120/29,20.37.195.0/29,20.37.224.104/29,20.38.84.72/29,20.38.136.104/29'
$range2 = '20.39.11.8/29,20.41.4.88/29,20.41.64.120/29,20.41.192.104/29,20.42.4.120/29,20.42.129.152/29,20.42.224.104/29,20.43.41.136/29'
$range3 = '20.43.65.128/29,20.43.130.80/29,20.45.112.104/29,20.45.192.104/29,20.72.18.248/29,20.150.160.96/29,20.189.106.112/29,20.192.161.104/29'
$range4 = '20.192.225.48/29,40.67.48.104/29,40.74.30.72/29,40.80.56.104/29,40.80.168.104/29,40.80.184.120/29,40.82.248.248/29,40.89.16.104/29'
$range5 = '51.12.41.8/29,51.12.193.8/29,51.104.25.128/29,51.105.80.104/29,51.105.88.104/29,51.107.48.104/29,51.107.144.104/29,51.120.40.104/29'
$range6 = '51.120.224.104/29,51.137.160.112/29,51.143.192.104/29,52.136.48.104/29,52.140.104.104/29,52.150.136.120/29,52.228.80.120/29,102.133.56.88/29'
$range7 = '102.133.216.88/29,147.243.0.0/16,191.233.9.120/29,191.235.225.128/29'


    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 150 -Action Allow -IpAddress $range1

    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 151 -Action Allow -IpAddress $range2

    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 152 -Action Allow -IpAddress $range3

    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 153 -Action Allow -IpAddress $range4

    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 154 -Action Allow -IpAddress $range5

    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 155 -Action Allow -IpAddress $range6

    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $rgName -WebAppName "$webApp" `
    -Name "Allow - FrontDoor BE" -Priority 156 -Action Allow -IpAddress $range7