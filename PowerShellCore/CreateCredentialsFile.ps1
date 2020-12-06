<# This script will generate some encrypted credentials for use in LogicMonitor scripts #>
$company = Read-Host -Prompt "LogicMonitor company"
$accessId = Read-Host -Prompt "LogicMonitor AccessId"
$accessKey = Read-Host -AsSecureString -Prompt "LogicMonitor AccessKey"
$apiCreds = 
@{
    Company   = $company;
    AccessId  = $accessId;
    AccessKey = ConvertFrom-SecureString -SecureString $accessKey;
}
$apiCreds |  ConvertTo-Json -Compress | Set-Content LogicMonitorCreds.json