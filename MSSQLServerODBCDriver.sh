#!/bin/bash

# Exit on Any Error
set -e

# Check Ubuntu Version is Supported or Not
if ! [[ "18.04 20.04 22.04 23.04 24.04" == *"$(lsb_release -rs)"* ]]; then
    exit
fi

# Add Microsoft Repository Keys and Source List
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# Update Package List
sudo apt-get update

# Accept the EULA and Install SQL Server Tools
echo msodbcsql18 msodbcsql/ACCEPT_EULA boolean true | sudo debconf-set-selections
sudo apt-get install -y msodbcsql18
sudo apt-get install -y mssql-tools18

# Update PATH and Apply Changes
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

