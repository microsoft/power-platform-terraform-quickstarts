#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Rerun the script using source: source ./set-local-env.sh"
    exit 1
fi

pushd ./tenant-configuration

export POWER_PLATFORM_CLIENT_ID=$(terraform show -json | jq -r '.values.outputs.client_id.value')
export POWER_PLATFORM_SECRET=$(terraform show -json | jq -r '.values.outputs.client_secret.value')
export POWER_PLATFORM_TENANT_ID=$(terraform show -json | jq -r '.values.outputs.tenant_id.value')

popd