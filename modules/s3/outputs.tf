output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Final S3 bucket name."
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "S3 bucket ARN."
}

output "random_suffix" {
  value       = format("%06d", random_integer.suffix.result)
  description = "Zero-padded 6-digit random suffix (min 000042)."
}

output "region" {
  value       = lower(var.region)
  description = "Region used in the name."
}
