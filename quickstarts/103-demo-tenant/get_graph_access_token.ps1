# Get the access token for Microsoft Graph API using Azure CLI
$accessToken = az account get-access-token --resource https://graph.microsoft.com --query accessToken --output tsv

# Output the access token as a JSON object
$output = @{
    accessToken = $accessToken
}

$output | ConvertTo-Json