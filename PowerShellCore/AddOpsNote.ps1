param(
    [Parameter(Mandatory)][string]$note,
    [int[]]$deviceGroupIds = @(),
    [int[]]$websiteGroupIds = @()
    # [string[]]$tags = @()
)
[string]$credsFile = "LogicMonitorCreds.json"

# Check whether the creds file exists
if (!(Test-Path $credsFile -PathType leaf)) {
    Write-Error "Couldn't find creds file '$credsFile'. Use CreateCredentialsFile.ps1 to create it."
    exit 1
}
$creds = Get-Content -Raw LogicMonitorCreds.json | ConvertFrom-Json
$creds.AccessKey = $creds.AccessKey | ConvertTo-SecureString 
[string]$company = $creds.Company
[string]$accessId = $creds.AccessId
[string]$accessKey = $creds.AccessKey | ConvertFrom-SecureString -AsPlainText

<# Use TLS 1.3 #>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

<# Setup the request #>
$requestMethod = 'POST'
$resourcePath = '/setting/opsnotes'
$request = @{
    note   = $note
    scopes = @(
    )
    # tags   = @(
    # )
}

# Add any DeviceGroups to the scope
if ($deviceGroupIds.Count -gt 0) {
    foreach ($id in $deviceGroupIds) {
        $request.scopes += @{type = "deviceGroup"; groupId = $id }
    }
}
# Add any WebsiteGroups to the scope
if ($websiteGroupIds.Count -gt 0) {
    foreach ($id in $websiteGroupIds) {
        $request.scopes += @{type = "websiteGroup"; groupId = $id }
    }
}
# # Add any tags
# if ($tags.Count -gt 0) {
#     foreach ($tag in $tags) {
#         $request.tags += $request.tags + $tag
#     }
# }

$data = $request | ConvertTo-Json
# $data
# exit

<# Construct URL #>
$url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath

<# Get current time in milliseconds #>
$epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

<# Construct Signature as per LogicMonitor instructions #>
$requestVars = $requestMethod + $epoch + $data + $resourcePath
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

try {
    <# Make Request #>
    $response = Invoke-RestMethod -Uri $url -Method $requestMethod -Body $data -Header $headers 
    Write-Host "Created OpsNote with id $($response.id)"
}
catch {
    <# Print status and body of response #>
    # $status = $response.status
    # $body = $response.data | ConvertTo-Json -Depth 5

    Write-Error "Failed to create OpsNote"
    Write-Error "ErrorDetails: $_"
    exit 1
}
