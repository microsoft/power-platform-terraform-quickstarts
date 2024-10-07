param (
    [string]$envName,
    [string]$firstName,
    [string]$lastName,
    [string]$domain
)

# Authenticate with Azure and get an access token for the Power Platform API
$accessToken = az account get-access-token --resource https://service.powerapps.com --query accessToken --output tsv

# Query the Power Platform API for the list of environments
$headers = @{
    "Authorization" = "Bearer $accessToken"
}
$environments = Invoke-RestMethod -Uri "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=2024-05-01" -Headers $headers

# Check if the environment already exists
$envExists = $environments.value | Where-Object { $_.properties.displayName -eq $envName }

# If the environment does not exist, create it
if (-not $envExists) {
    # Create environment on behalf of the user
    pac admin create --name "$envName" --type "Developer" --user "$firstName.$lastName@$domain"
    
    # Query the Power Platform API again to get the updated list of environments
    $environments = Invoke-RestMethod -Uri "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=2024-05-01" -Headers $headers
    $envExists = $environments.value | Where-Object { $_.properties.displayName -eq $envName }
}

# Extract the environment ID and instance URL from the output
$envId = $envExists.name
$instanceUrl = $envExists.properties.linkedEnvironmentMetadata.instanceUrl

# Output the environment ID and instance URL
Write-Output "environment_id=$envId`ninstance_url=$instanceUrl"
