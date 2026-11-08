#!/bin/bash

set -euo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
RAW_BUCKET="nusa-raw-data-${ACCOUNT_ID}"

echo "Starting data ingestion to S3 bucket: ${RAW_BUCKET}"

if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed."
    exit 1
fi

if [ ! -d "data" ]; then
    echo "Error: 'data' directory not found. Run this script from the project root."
    exit 1
fi

echo "Uploading datasets..."
aws s3 cp data/transactions.csv s3://${RAW_BUCKET}/transactions/
aws s3 cp data/user_events.csv  s3://${RAW_BUCKET}/user_events/
aws s3 cp data/shipments.csv    s3://${RAW_BUCKET}/shipments/
aws s3 cp data/sellers.csv      s3://${RAW_BUCKET}/sellers/

echo "Uploading ETL scripts..."
aws s3 cp scripts/etl_transactions.py s3://${RAW_BUCKET}/scripts/
aws s3 cp scripts/etl_shipments.py    s3://${RAW_BUCKET}/scripts/
aws s3 cp scripts/etl_sellers.py      s3://${RAW_BUCKET}/scripts/

echo "Uploading EMR scripts..."
aws s3 cp scripts/emr/emr_seller_scoring.py    s3://${RAW_BUCKET}/scripts/emr/
aws s3 cp scripts/emr/emr_user_segmentation.py s3://${RAW_BUCKET}/scripts/emr/

echo "Data ingestion completed successfully."