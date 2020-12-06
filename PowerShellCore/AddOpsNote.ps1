param(
    [Parameter(Mandatory)][string]$note,
    [int[]]$deviceGroupIds = @()
)
[string]$credsFile = "LogicMonitorCreds.json"

# Check whether the creds file exists
if (!(Test-Path $credsFile -PathType leaf)) {
    Write-Error "Couldn't find creds file '$credsFile'"
    exit 1
}
$creds = Get-Content -Raw LogicMonitorCreds.json | ConvertFrom-Json
$creds.AccessKey = $creds.AccessKey | ConvertTo-SecureString 
[string]$company = $creds.Company
[string]$accessId = $creds.AccessId
[string]$accessKey = $creds.AccessKey | ConvertFrom-SecureString -AsPlainText

<# Use TLS 1.3 #>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

<# Setup the request content #>
$resourcePath = '/setting/opsnotes'
$request = @{
    note   = $note
    scopes = @(
    )
}

# Add any DeviceGroups
if ($deviceGroupIds.Count -gt 0) {
    foreach ($id in $deviceGroupIds) {
        $request.scopes = $request.scopes + @{type = "deviceGroup"; groupId = $id }
    }
}

$data = $request | ConvertTo-Json
#$data
#exit

<# Construct URL #>
$url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath

<# Get current time in milliseconds #>
$epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

<# Construct Signature as per LogicMonitor instructions #>
$requestVars = 'POST' + $epoch + $data + $resourcePath
$hmac = New-Object System.Security.Cryptography.HMACSHA256
$hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
$signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
$signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
$signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

<# Construct Headers #>
$auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $auth)
$headers.Add("Content-Type", 'application/json')
$headers.Add("X-Version", '2')

<# Make Request #>
$response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers 

<# Print status and body of response #>
$status = $response.status
$body = $response.data | ConvertTo-Json -Depth 5

Write-Host "Status: $status"
Write-Host "Response: $body"