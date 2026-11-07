resource "aws_glue_catalog_database" "nusa" {
  name = "${var.project_prefix}-database"
}

resource "aws_glue_catalog_table" "transactions" {
  name          = "transactions"
  database_name = aws_glue_catalog_database.nusa.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification           = "csv"
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.raw.bucket}/transactions/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        separatorChar = ","
        quoteChar     = "\""
      }
    }

    columns {
      name = "transaction_id"
      type = "string"
    }
    columns {
      name = "user_id"
      type = "string"
    }
    columns {
      name = "total_amount"
      type = "double"
    }
  }
}

# Ulangi untuk user_events, shipments, sellers
resource "aws_iam_role" "glue_role" {
  name = "${var.project_prefix}-glue-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3" {
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.raw.arn,
        "${aws_s3_bucket.raw.arn}/*",
        aws_s3_bucket.processed.arn,
        "${aws_s3_bucket.processed.arn}/*"
      ]
    }]
  })
}

resource "aws_glue_job" "etl_transactions" {
  name     = "${var.project_prefix}-etl-transactions"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.raw.bucket}/scripts/etl_transactions.py"
    python_version  = "3"
  }

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 30
  max_retries       = 1

  default_arguments = {
    "--input_path"          = "s3://${aws_s3_bucket.raw.bucket}/transactions/"
    "--output_path"         = "s3://${aws_s3_bucket.processed.bucket}/transactions/"
    "--database_name"       = aws_glue_catalog_database.nusa.name
    "--table_name"          = "transactions"
    "--job-bookmark-option" = "job-bookmark-disable"
  }

  depends_on = [aws_s3_object.etl_transactions]
}

# Ulangi untuk etl_shipments, etl_sellers