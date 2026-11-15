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

data "aws_caller_identity" "current" {}

# Explicit key policy. "Resource *" in a key policy means "this key only", and the
# account root principal lets normal IAM permissions control who may use the key.
data "aws_iam_policy_document" "kms" {
  #checkov:skip=CKV_AWS_109:In a KMS key policy "*" means this key only; the account root statement is the AWS standard pattern.
  #checkov:skip=CKV_AWS_111:Same as above: scoped to this key by definition.
  #checkov:skip=CKV_AWS_356:Same as above: "*" refers to this key only.
  statement {
    sid       = "AccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# Encryption key for the bucket. Automatic yearly rotation is on.
resource "aws_kms_key" "this" {
  description             = "Key for the ${var.bucket_name} bucket"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = var.tags

  depends_on = [terraform_data.region_guard]
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.bucket_name}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_144:Cross-region replication adds cost and may move data outside the EU. Optional extra, not part of the baseline.
  #checkov:skip=CKV2_AWS_62:Event notifications are not a security control for this baseline.
  #checkov:skip=CKV_AWS_18:Access logging needs a separate log bucket. Planned as an optional input; CloudTrail already records API activity.
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

# Cleans up old object versions and half-finished uploads so storage is not kept forever.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "clean-up-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
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
