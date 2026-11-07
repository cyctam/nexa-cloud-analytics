output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "raw_bucket" {
  value = aws_s3_bucket.raw.bucket
}

output "processed_bucket" {
  value = aws_s3_bucket.processed.bucket
}

output "curated_bucket" {
  value = aws_s3_bucket.curated.bucket
}