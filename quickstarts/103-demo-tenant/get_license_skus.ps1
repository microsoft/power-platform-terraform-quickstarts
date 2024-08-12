$ErrorActionPreference = "Stop"
$logFile = "trace.log"

try {
    # Redirect output to trace.log
    "Getting access token..." | Out-File -FilePath $logFile -Append
    $token = az account get-access-token --resource=https://graph.microsoft.com --query accessToken --output tsv
    "Access token obtained" | Out-File -FilePath $logFile -Append

    # Query the subscribed SKUs
    $headers = @{
        Authorization = "Bearer $token"
    }
    "Querying subscribed SKUs..." | Out-File -FilePath $logFile -Append
    $skus = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/subscribedSkus" -Headers $headers
    "Subscribed SKUs: $($skus | ConvertTo-Json -Compress -Depth 100)" | Out-File -FilePath $logFile -Append

    # Filter the SKUs
    $filteredSkus = $skus.value | Where-Object {
        $_.skuPartNumber -eq "POWERAPPS_DEV" -or # Power Apps for Developer
        $_.skuPartNumber -eq "FLOW_FREE" -or # Power Automate Trial
        $_.skuPartNumber -eq "POWERAUTOMATE_ATTENDED_RPA" # Power Automate Premium
        $_.skuPartNumber -eq "SPB" # Mirosoft 365 Business Premium
    }
    "Filtered SKUs: $($filteredSkus | ConvertTo-Json -Compress  -Depth 100)" | Out-File -FilePath $logFile -Append

    # Return only the skuId of the matches as a comma-delimited string
    $skuIds = $filteredSkus | Select-Object -ExpandProperty skuId
    $result = @{ result = ($skuIds -join ",") }

    $result | ConvertTo-Json -Compress -Depth 100 | Out-File -FilePath $logFile -Append
    $result | ConvertTo-Json -Compress -Depth 100
} catch {
    $errorResult = @{ error = $_.Exception.Message }
    $errorResult | ConvertTo-Json -Compress -Depth 100
    exit 1
}
