# NusaCommerce Analytics Platform

End-to-End Cloud Data & Analytics Pipeline for E-Commerce Intelligence on AWS.

## Architecture
This platform is built on five interconnected layers:
- **Ingestion**: S3, Kinesis Data Streams, Kinesis Firehose
- **Processing**: Glue ETL, EMR (Spark), Step Functions, EventBridge
- **Storage**: Redshift, DynamoDB, S3 (data lake)
- **Security**: WAF, Secrets Manager, API Key authentication
- **Frontend**: AWS Amplify

## Infrastructure as Code (Terraform)
All infrastructure is provisioned using Terraform. To deploy:
```bash
cd terraform
terraform init
terraform apply
