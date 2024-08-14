Sure, I can help with that. Here is the equivalent PowerShell (pwsh) script:

param (
    [string]$client_id,
    [string]$action
)

if (-not $client_id) {
    Write-Host "No client_id argument supplied"
    exit 1
}

if (-not $action) {
    Write-Host "No action argument supplied"
    exit 1
}

if ($action -ne "create" -and $action -ne "destroy") {
    Write-Host "Invalid action argument supplied. Must be either 'create' or 'destroy'"
    exit 1
}

$access_token = az account get-access-token --scope https://service.powerapps.com//.default --query accessToken --output tsv
$api_version = "2020-10-01"
$url = "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/adminApplications/$client_id?api-version=$api_version"

if ($action -eq "create") {
    Invoke-RestMethod -Method Put -Uri $url -Headers @{Authorization = "Bearer $access_token"; Accept = "application/json"; "Content-Length" = "0"}
} elseif ($action -eq "destroy") {
    Invoke-RestMethod -Method Delete -Uri $url -Headers @{Authorization = "Bearer $access_token"; Accept = "application/json"; "Content-Length" = "0"}
}
