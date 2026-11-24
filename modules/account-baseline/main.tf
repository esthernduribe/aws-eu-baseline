# Account-wide password rules for IAM users.
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  max_password_age               = var.max_password_age_days
  password_reuse_prevention      = var.password_reuse_prevention
  allow_users_to_change_password = true
  hard_expiry                    = false
}

# Blocks public access for every S3 bucket in the account, including future ones.
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
