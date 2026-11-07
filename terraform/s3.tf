locals {
  account_id = data.aws_caller_identity.current.account_id
}

# --- RAW BUCKET ---
resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_prefix}-raw-data-${local.account_id}"
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "raw" {
  bucket                  = aws_s3_bucket.raw.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id
  rule {
    id     = "glacier-then-delete"
    status = "Enabled"
    filter {}
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 120
    }
  }
}

# --- PROCESSED BUCKET ---
resource "aws_s3_bucket" "processed" {
  bucket = "${var.project_prefix}-processed-data-${local.account_id}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed" {
  bucket = aws_s3_bucket.processed.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed" {
  bucket                  = aws_s3_bucket.processed.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "processed" {
  bucket = aws_s3_bucket.processed.id
  rule {
    id     = "glacier-then-delete"
    status = "Enabled"
    filter {}
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 120
    }
  }
}

# --- CURATED BUCKET ---
resource "aws_s3_bucket" "curated" {
  bucket = "${var.project_prefix}-curated-data-${local.account_id}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated" {
  bucket = aws_s3_bucket.curated.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "curated" {
  bucket                  = aws_s3_bucket.curated.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "curated" {
  bucket = aws_s3_bucket.curated.id
  rule {
    id     = "glacier-then-delete"
    status = "Enabled"
    filter {}
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 120
    }
  }
}

resource "aws_s3_object" "transactions_csv" {
  bucket = aws_s3_bucket.raw.id
  key    = "transactions/transactions.csv"
  source = "../data/transactions.csv"
  etag   = filemd5("../data/transactions.csv")
}

resource "aws_s3_object" "user_events_csv" {
  bucket = aws_s3_bucket.raw.id
  key    = "user_events/user_events.csv"
  source = "../data/user_events.csv"
  etag   = filemd5("../data/user_events.csv")
}

resource "aws_s3_object" "shipments_csv" {
  bucket = aws_s3_bucket.raw.id
  key    = "shipments/shipments.csv"
  source = "../data/shipments.csv"
  etag   = filemd5("../data/shipments.csv")
}

resource "aws_s3_object" "sellers_csv" {
  bucket = aws_s3_bucket.raw.id
  key    = "sellers/sellers.csv"
  source = "../data/sellers.csv"
  etag   = filemd5("../data/sellers.csv")
}

resource "aws_s3_object" "etl_transactions" {
  bucket = aws_s3_bucket.raw.id
  key    = "scripts/etl_transactions.py"
  source = "../scripts/etl_transactions.py"
  etag   = filemd5("../scripts/etl_transactions.py")
}

resource "aws_s3_object" "etl_shipments" {
  bucket = aws_s3_bucket.raw.id
  key    = "scripts/etl_shipments.py"
  source = "../scripts/etl_shipments.py"
  etag   = filemd5("../scripts/etl_shipments.py")
}

resource "aws_s3_object" "etl_sellers" {
  bucket = aws_s3_bucket.raw.id
  key    = "scripts/etl_sellers.py"
  source = "../scripts/etl_sellers.py"
  etag   = filemd5("../scripts/etl_sellers.py")
}

resource "aws_s3_object" "curated_placeholders" {
  for_each = toset(["aggregates/", "reports/", "athena-results/", "ml-features/"])
  bucket   = aws_s3_bucket.curated.id
  key      = "${each.value}.keep"
  content  = ""
}