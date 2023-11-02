#!/bin/bash

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --client_id)
        client_id="$2"
        shift
        shift
        ;;
        --action)
        action="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

if [ -z "$client_id" ]
    then
        echo "No client_id argument supplied"
        exit 1
fi

if [ -z "$action" ]
    then
        echo "No action argument supplied"
        exit 1
fi

if [ "$action" != "create" ] && [ "$action" != "destroy" ]
    then
        echo "Invalid action argument supplied. Must be either 'create' or 'destroy'"
        exit 1
fi

access_token=$(az account get-access-token --scope https://service.powerapps.com//.default --query accessToken --output tsv)
api_version="2020-10-01"
url="https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/adminApplications/$client_id?api-version=$api_version"

if [ "$action" == "create" ]
    then
        curl -X PUT -H "Authorization: Bearer $access_token" -H "Accept: application/json" -H "Content-Length: 0" $url
elif [ "$action" == "destroy" ]
    then
        curl -X DELETE -H "Authorization: Bearer $access_token" -H "Accept: application/json" -H "Content-Length: 0" $url
fi
