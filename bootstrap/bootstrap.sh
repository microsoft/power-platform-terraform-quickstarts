#!/bin/bash

if [ "$#" -eq 4 ]; then
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            --subscription_id)
            subscription_id="$2"
            shift # past argument
            shift # past value
            ;;
            --location)
            location="$2"
            shift # past argument
            shift # past value
            ;;
            # --github_pat_token)
            # github_pat_token="$2"
            # shift # past argument
            # shift # past value
            # ;;
            *)    # unknown option
            echo "Unknown option: $key"
            exit 1
            ;;
        esac
    done

    if [ -z "$subscription_id" ]; then
        echo "Subscription ID is required. Please pass it in the form of --subscription_id 234..."
        exit 1
    fi

    if [ -z "$location" ]; then
        echo "Location is required. Please pass it in the form of --location WestUS"
        exit 1
    fi

    az login
    az account set --subscription $subscription_id

    echo "Using the following subscription:"
    az account show

    echo "Installing Bicep..."
    az bicep install
    az bicep version

    echo "Deploying Terraform Backend resources..."
    deploymentJson=$(az deployment sub create --location $location --template-file ./tf-backend/tf-subscription.bicep)
    echo $deploymentJson | jq -r '.properties.outputs | to_entries | map("\(.key) = \"\(.value.value)\"") | .[]' > ../backend.tfvars

    touch ./bootstrap_backend.tfvars
    cat ../backend.tfvars > ./tenant-configuration/bootstrap_backend.tfvars
    echo "container_name = \"tfstate\"" >> ./tenant-configuration/bootstrap_backend.tfvars
    echo "key = \"tenant-configuration.terraform.tfstate\"" >> ./tenant-configuration/bootstrap_backend.tfvars

    echo "Terraform backend configuration has been written to ../backend.tfvars"
    cat ../backend.tfvars

    pushd ./tenant-configuration

    # Enable AzureRM backend in the main.tf file
    sed -i 's/^[[:space:]]*#backend "azurerm" {}/backend "azurerm" {}/' main.tf

    echo "Terraform init..."
    # Call terraform init with backend.tfvars as backend config file
    TF_IN_AUTOMATION=1 terraform init -backend-config=./bootstrap_backend.tfvars

    echo "Terraform apply..."
    # Run terraform apply and get the output values into variables
    TF_IN_AUTOMATION=1 terraform apply --auto-approve -var-file=./bootstrap_backend.tfvars
    
elif [ "$#" -eq 0 ]; then
   #az login --allow-no-subscriptions
   pushd ./tenant-configuration

   # Disable AzureRM backend in the main.tf file
   sed -i 's/^[[:space:]]*backend "azurerm" {}/#backend "azurerm" {}/' main.tf

   echo "Terraform init..."
   # Call terraform init with backend.tfvars as backend config file
   TF_IN_AUTOMATION=1 terraform init

   echo "Terraform apply..."
   # Run terraform apply and get the output values into variables
   TF_IN_AUTOMATION=1 terraform apply --auto-approve
    
else
    echo "Invalid number of arguments. Please pass either 0 or 4 arguments."
    exit 1
fi

export POWER_PLATFORM_CLIENT_ID=$(terraform show -json | jq -r '.values.outputs.client_id.value')
export POWER_PLATFORM_SECRET=$(terraform show -json | jq -r '.values.outputs.client_secret.value')
export POWER_PLATFORM_TENANT_ID=$(terraform show -json | jq -r '.values.outputs.tenant_id.value')

popd

echo "Bootstrap complete!"
echo "You have to grant permissions to the new 'Power Platform Admin Service' service principal in the Azure portal to access the Power Platform resources."
echo ""
echo "You now have following options to login to the Power Platform in Terraform:"
echo "1. Use the following environment variables that can be set using /bootstrap/set-local-env.sh:"
echo "    provider 'powerplatform' {
    }
    "

echo "2. Use the client_id, client_secret and tenant_id directly:
    provider 'powerplatform' {
      client_id     = var.client_id
      client_secret = var.client_secret
      tenant_id     = var.tenant_id
    }
    "
echo "3. Use Azure CLI to login that will be used in the provider block:
    For login use: az login --allow-no-subscriptions --scope api://powerplatform_provider_terraform/.default

    provider 'powerplatform' {
      use_cli = true
    }"