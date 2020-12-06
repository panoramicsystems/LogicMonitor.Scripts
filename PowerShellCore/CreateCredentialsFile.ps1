<# This script will generate some encrypted credentials for use in LogicMonitor scripts #>
$credentialsFile = "LogicMonitorCreds.json"

$company = Read-Host -Prompt "LogicMonitor company"
$accessId = Read-Host -Prompt "LogicMonitor AccessId"
$accessKey = Read-Host -AsSecureString -Prompt "LogicMonitor AccessKey"
$apiCreds = 
@{
    Company   = $company;
    AccessId  = $accessId;
    AccessKey = ConvertFrom-SecureString -SecureString $accessKey;
}
Write-Host "Writing to $credentialsFile..." -NoNewline
$apiCreds |  ConvertTo-Json | Set-Content $credentialsFile
Write-Host "done."
