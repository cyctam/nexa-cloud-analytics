#!/bin/bash
set -euo pipefail

if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed."
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed."
    exit 1
fi

if [ ! -d "terraform" ]; then
    echo "Error: 'terraform' directory not found. Run this script from the project root."
    exit 1
fi

echo "Starting infrastructure deployment..."
cd terraform

echo "Initializing Terraform..."
terraform init

echo "Validating configuration..."
terraform validate

echo "Generating execution plan..."
terraform plan -out=tfplan

echo "Applying infrastructure changes..."
terraform apply tfplan

echo "Cleaning up temporary files..."
rm -f tfplan

echo "Deployment completed successfully."#!/bin/bash


set -euo pipefail

if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed."
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed."
    exit 1
fi

if [ ! -d "terraform" ]; then
    echo "Error: 'terraform' directory not found. Run this script from the project root."
    exit 1
fi

echo "Starting infrastructure deployment..."
cd terraform

echo "Initializing Terraform..."
terraform init

echo "Validating configuration..."
terraform validate

echo "Generating execution plan..."
terraform plan -out=tfplan

echo "Applying infrastructure changes..."
terraform apply tfplan

echo "Cleaning up temporary files..."
rm -f tfplan

echo "Deployment completed successfully."