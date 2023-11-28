#!/bin/bash

# Check if GitHub CLI is installed
# if ! command -v gh &> /dev/null
# then
#     # Install GitHub CLI
#     sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
#     sudo apt-add-repository https://cli.github.com/packages
#     sudo apt update
#     sudo apt install gh

#     # Check if installation was successful
#     if ! command -v gh &> /dev/null
#     then
#         echo "GitHub CLI installation failed. Please try again."
#         exit
#     fi
# fi

# Set the repository and release information
repo="microsoft/terraform-provider-power-platform"
release="v0.4.0-preview"

# Set the download directory
download_dir="/usr/share/terraform/providers/registry.terraform.io/microsoft/power-platform"

# Create the download directory if it doesn't exist
if [ ! -d "$download_dir" ]
then
    mkdir -p "$download_dir"
fi

# Download the release assets
gh release download "$release" --repo "$repo" --pattern "*.zip" --dir "$download_dir" --clobber

cp mirror.tfrc $download_dir

chown -R vscode $download_dir

export TF_CLI_CONFIG_FILE="$download_dir/mirror.tfrc"

