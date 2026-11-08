# NEXA — Cloud Data & Analytics Platform

An end-to-end cloud data and analytics platform for e-commerce intelligence, built on AWS.

## Architecture

NEXA is organized into five interconnected layers:

- **Ingestion**: Amazon S3, Kinesis Data Streams, Kinesis Data Firehose
- **Processing**: AWS Glue ETL, Amazon EMR (Spark), Step Functions, EventBridge
- **Storage**: Amazon Redshift, DynamoDB, Amazon S3 (Data Lake)
- **Security**: AWS WAF, Secrets Manager, API Key Authentication
- **Frontend**: AWS Amplify

## Infrastructure as Code

Infrastructure provisioning and deployment automation are managed using Terraform.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Review the Terraform plan and AWS resource costs before applying.
