if ($MyInvocation.MyCommand.Path -eq $PSCommandPath) {
    Write-Host "Rerun the script using source: . .\set-local-env.ps1"
    exit 1
}

Push-Location ./tenant-configuration

$POWER_PLATFORM_CLIENT_ID = (terraform show -json | ConvertFrom-Json).values.outputs.client_id.value
$POWER_PLATFORM_SECRET = (terraform show -json | ConvertFrom-Json).values.outputs.client_secret.value
$POWER_PLATFORM_TENANT_ID = (terraform show -json | ConvertFrom-Json).values.outputs.tenant_id.value

Pop-Location