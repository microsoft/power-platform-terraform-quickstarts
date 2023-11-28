#!/bin/bash

while [[ $# -gt 0 ]]
do
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
    --github_repo)
    github_repo="$2"
    shift # past argument
    shift # past value
    ;;
    --github_pat_token)
    github_pat_token="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Unknown option: $key"
    exit 1
    ;;
esac
done

if [ -z "$subscription_id" ]
then
    echo "Subscription ID is required. Please pass it in the form of --subscription_id 234..."
    exit 1
fi

if [ -z "$location" ]
then
    echo "Location is required. Please pass it in the form of --location WestUS"
    exit 1
fi

if [ -z "$github_repo" ]
then
    echo "GitHub repo is required. Please pass it in the form of --github_repo owner/repo"
    exit 1
fi

#This is needed as long as quickstarts repo is private
if [ -z "$github_pat_token" ]
then
    echo "GitHub PAT token is required. Please pass it in the form of --github_pat_token <token>"
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

echo "Terraform backend configuration has been written to ../backend.tfvars"
cat ../backend.tfvars

pushd ./tenant-configuration

echo "Terraform init..."
# Call terraform init with backend.tfvars as backend config file
TF_IN_AUTOMATION=1 terraform init -backend-config=../../backend.tfvars

#This is needed as long as quickstarts repo is private
export GITHUB_TOKEN=$github_pat_token
#---------------------------------------------

echo "Terraform apply..."
# Run terraform apply and get the output values into variables
TF_IN_AUTOMATION=1 terraform apply --auto-approve -var-file=../../backend.tfvars -var="github_repo=$github_repo"

export POWER_PLATFORM_CLIENT_ID=$(terraform show -json | jq -r '.values.outputs.client_id.value')
export POWER_PLATFORM_SECRET=$(terraform show -json | jq -r '.values.outputs.client_secret.value')
export POWER_PLATFORM_TENANT_ID=$(terraform show -json | jq -r '.values.outputs.tenant_id.value')

popd

echo "Bootstrap complete! Read ../src/README.md for next steps."