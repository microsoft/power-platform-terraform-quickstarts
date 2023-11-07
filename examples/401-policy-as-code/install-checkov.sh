#!/bin/bash

# Update package list
sudo apt-get update

# Install Python3 and pip
sudo apt-get install -y python3 python3-pip

# Install Checkov using pip3
sudo pip3 install checkov
