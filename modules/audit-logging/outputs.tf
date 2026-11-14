output "trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.this.arn
}

output "log_bucket_name" {
  description = "Name of the bucket that stores the logs."
  value       = aws_s3_bucket.logs.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key that encrypts the logs."
  value       = aws_kms_key.logs.arn
}
