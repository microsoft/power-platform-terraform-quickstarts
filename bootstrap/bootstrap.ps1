param (
    [string]$subscription_id,
    [string]$location
)

$terrformPath = "terraform"

try {
    terraform --version
    Write-Output "Terraform is installed and available in the PATH."
} catch {
    $terrformPath = Join-Path -Path $env:ProgramData -ChildPath "Terraform\terraform.exe"
    if ( -not (Test-Path $terrformPath) ) {
        Write-Error "Unable to find terraform"
        exit
    }
}

if ($PSCmdlet.MyInvocation.BoundParameters.Count -eq 2) {
    if (-not $subscription_id) {
        Write-Host "Subscription ID is required. Please pass it in the form of --subscription_id 234..."
        exit 1
    }

    if (-not $location) {
        Write-Host "Location is required. Please pass it in the form of --location WestUS"
        exit 1
    }

    az login --use-device-code
    az account set --subscription $subscription_id

    Write-Host "Using the following subscription:"
    az account show

    Write-Host "Installing Bicep..."
    az bicep install
    az bicep version

    Write-Host "Deploying Terraform Backend resources..."
    $deploymentJson = az deployment sub create --location $location --template-file ./tf-backend/tf-subscription.bicep
    $deploymentJson | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputs | ForEach-Object { "$($_.Key) = '$($_.Value.value)'" } | Out-File -FilePath ../backend.tfvars -Encoding utf8

    New-Item -ItemType File -Path ./bootstrap_backend.tfvars -Force
    Get-Content ../backend.tfvars | Out-File -FilePath ./tenant-configuration/bootstrap_backend.tfvars -Encoding utf8
    Add-Content -Path ./tenant-configuration/bootstrap_backend.tfvars -Value "container_name = 'tfstate'"
    Add-Content -Path ./tenant-configuration/bootstrap_backend.tfvars -Value "key = 'tenant-configuration.terraform.tfstate'"

    Write-Host "Terraform backend configuration has been written to ../backend.tfvars"
    Get-Content ../backend.tfvars

    Push-Location ./tenant-configuration

    # Enable AzureRM backend in the main.tf file
    (Get-Content main.tf) -replace '^[\s]*#backend "azurerm" {}', 'backend "azurerm" {}' | Set-Content main.tf

    Write-Host "Terraform init..."
    # Call terraform init with backend.tfvars as backend config file
    $env:TF_IN_AUTOMATION = 1
    & $terrformPath init -backend-config=./bootstrap_backend.tfvars

    Write-Host "Terraform apply..."
    # Run terraform apply and get the output values into variables
    & $terrformPath apply --auto-approve -var-file=./bootstrap_backend.tfvars

} elseif ($PSCmdlet.MyInvocation.BoundParameters.Count -eq 0) {
    az login --allow-no-subscriptions --use-device-code
    Push-Location ./tenant-configuration

    # Disable AzureRM backend in the main.tf file
    (Get-Content main.tf) -replace '^[\s]*backend "azurerm" {}', '#backend "azurerm" {}' | Set-Content main.tf

    Write-Host "Terraform init..."
    # Call terraform init with backend.tfvars as backend config file
    $env:TF_IN_AUTOMATION = 1
    & $terrformPath init

    Write-Host "Terraform apply..."
    # Run terraform apply and get the output values into variables
    & $terrformPath apply --auto-approve

} else {
    Write-Host "Invalid number of arguments. Please pass either 0 or 2 arguments."
    exit 1
}

$env:POWER_PLATFORM_CLIENT_ID = (& $terrformPath show -json | ConvertFrom-Json).values.outputs.client_id.value
$env:POWER_PLATFORM_SECRET = (& $terrformPath show -json | ConvertFrom-Json).values.outputs.client_secret.value
$env:POWER_PLATFORM_TENANT_ID = (& $terrformPath show -json | ConvertFrom-Json).values.outputs.tenant_id.value

Pop-Location

Write-Host "Bootstrap complete!"
Write-Host ""
Write-Host "You have to grant permissions to the new 'Power Platform Admin Service' service principal in the Azure portal to access the Power Platform resources."
Write-Host ""
Write-Host "You now have following options to login to the Power Platform in Terraform:"
Write-Host "1. Use the following environment variables that can be set using /bootstrap/set-local-env.sh:"
Write-Host "    provider 'powerplatform' {"
Write-Host "    }"
Write-Host ""
Write-Host "2. Use the client_id, client_secret and tenant_id directly:"
Write-Host "    provider 'powerplatform' {"
Write-Host "      client_id     = var.client_id"
Write-Host "      client_secret = var.client_secret"
Write-Host "      tenant_id     = var.tenant_id"
Write-Host "    }"
Write-Host ""
Write-Host "3. Use Azure CLI to login that will be used in the provider block:"
Write-Host "    For login use: az login --allow-no-subscriptions --scope api://power-platform_provider_terraform/.default"
Write-Host ""
Write-Host "    provider 'powerplatform' {"
Write-Host "      use_cli = true"
Write-Host "    }"
