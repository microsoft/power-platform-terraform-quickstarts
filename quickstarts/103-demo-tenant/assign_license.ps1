param (
    [string]$groupId,
    [string]$licenseSkus
)

# Function to get the access token from the logged-in Azure CLI context
function Get-AccessToken {
    $response = az account get-access-token --resource https://graph.microsoft.com
    $token = $response | ConvertFrom-Json
    return $token.accessToken
}

# Get the access token
$accessToken = Get-AccessToken

# Get the assigned licenses for the group
$group = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/groups/$groupId" -Headers @{Authorization = "Bearer $accessToken"}
$assignedLicenses = $group.assignedLicenses

# Initialize the list of licenses to add
$licensesToAdd = @()

foreach ($sku in ($licenseSkus -split ',')) {
    # Check if the SKU is already assigned to the group
    $isAssigned = $assignedLicenses | Where-Object { $_.skuId -eq $sku }

    if ($null -eq $isAssigned) {
        Write-Output "Adding SKU: $sku to the list of licenses to assign"
        $licensesToAdd += @{skuId = $sku; disabledPlans = @()}
    } else {
        Write-Output "SKU: $sku is already assigned to Group: $groupId"
    }
}

if ($licensesToAdd.Count -gt 0) {
    $body = @{
        addLicenses = $licensesToAdd
        removeLicenses = @()
    }
    $jsonBody = $body | ConvertTo-Json -Depth 3
    Write-Output "JSON Body: $jsonBody"  # Debugging output
    Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/assignLicense" -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"} -Body $jsonBody
} else {
    Write-Output "No new SKUs to assign."
}
