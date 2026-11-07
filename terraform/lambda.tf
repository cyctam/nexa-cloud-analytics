data "archive_file" "stream_processor" {
  type        = "zip"
  source_file = "../lambda/stream_processor.py"
  output_path = "${path.module}/builds/stream_processor.zip"
}

data "archive_file" "api_handler" {
  type        = "zip"
  source_file = "../lambda/api_handler.py"
  output_path = "${path.module}/builds/api_handler.zip"
}

data "archive_file" "redshift_loader" {
  type        = "zip"
  source_file = "../lambda/redshift_loader.py"
  output_path = "${path.module}/builds/redshift_loader.zip"
}

data "archive_file" "view_refresher" {
  type        = "zip"
  source_file = "../lambda/view_refresher.py"
  output_path = "${path.module}/builds/view_refresher.zip"
}

data "archive_file" "validate_input" {
  type        = "zip"
  source_file = "../lambda/validate_input.py"
  output_path = "${path.module}/builds/validate_input.zip"
}

data "archive_file" "ml_loader" {
  type        = "zip"
  source_file = "../lambda/ml_loader.py"
  output_path = "${path.module}/builds/ml_loader.zip"
}

# IAM role untuk Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_prefix}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_access" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:Query",
          "kinesis:GetRecords", "kinesis:GetShardIterator", "kinesis:DescribeStream",
          "s3:GetObject", "s3:PutObject", "s3:ListBucket",
          "athena:StartQueryExecution", "athena:GetQueryExecution", "athena:GetQueryResults",
          "secretsmanager:GetSecretValue",
          "sns:Publish",
          "states:StartExecution", "states:DescribeExecution"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "stream_processor" {
  function_name    = "${var.project_prefix}-stream-processor"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  handler          = "stream_processor.lambda_handler"
  filename         = data.archive_file.stream_processor.output_path
  source_code_hash = data.archive_file.stream_processor.output_base64sha256
  memory_size      = 256
  timeout          = 60

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.realtime_metrics.name
    }
  }
}

resource "aws_lambda_function" "api_handler" {
  function_name    = "${var.project_prefix}-api-handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  handler          = "api_handler.lambda_handler"
  filename         = data.archive_file.api_handler.output_path
  source_code_hash = data.archive_file.api_handler.output_base64sha256
  memory_size      = 512
  timeout          = 29

  environment {
    variables = {
      DYNAMODB_TABLE     = aws_dynamodb_table.realtime_metrics.name
      REDSHIFT_WORKGROUP = "${var.project_prefix}-warehouse"
      REDSHIFT_DATABASE  = "nusacommerce"
      RAW_BUCKET         = aws_s3_bucket.raw.bucket
      PROCESSED_BUCKET   = aws_s3_bucket.processed.bucket
      CURATED_BUCKET     = aws_s3_bucket.curated.bucket
    }
  }
}

# Ulangi untuk redshift_loader, view_refresher, validate_input, ml_loader

# Event source mapping Kinesis → stream_processor
resource "aws_lambda_event_source_mapping" "kinesis_stream" {
  event_source_arn  = aws_kinesis_stream.events.arn
  function_name     = aws_lambda_function.stream_processor.arn
  batch_size        = 100
  starting_position = "LATEST"
}