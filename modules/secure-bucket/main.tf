data "aws_region" "current" {}

# Region guard: stops the plan if the module is used outside the allowed regions.
resource "terraform_data" "region_guard" {
  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.region)
      error_message = "Region ${data.aws_region.current.region} is not in allowed_regions. This baseline only deploys to EU regions."
    }
  }
}

# Encryption key for the bucket. Automatic yearly rotation is on.
resource "aws_kms_key" "this" {
  description             = "Key for the ${var.bucket_name} bucket"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days
  tags                    = var.tags

  depends_on = [terraform_data.region_guard]
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.bucket_name}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags

  depends_on = [terraform_data.region_guard]
}

# Turns off ACLs so only policies control access.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Blocks every route to making the bucket public.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Everything written to the bucket is encrypted with our KMS key.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.this.arn
    }
    bucket_key_enabled = true
  }
}

# Keeps old versions of objects so accidental deletes can be undone.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Refuses any request that does not use HTTPS.
data "aws_iam_policy_document" "tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tls_only" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.tls_only.json

  # Avoids two changes to the bucket happening at the same moment.
  depends_on = [aws_s3_bucket_public_access_block.this]
}
