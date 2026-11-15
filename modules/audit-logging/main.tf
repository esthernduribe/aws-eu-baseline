data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.region
  bucket_name = "${var.name_prefix}-audit-logs-${local.account_id}"
  # Built by hand so the key and bucket policies can refer to the trail
  # without creating a circular dependency.
  trail_arn = "arn:aws:cloudtrail:${local.region}:${local.account_id}:trail/${var.trail_name}"
}

# Region guard: stops the plan if the module is used outside the allowed regions.
resource "terraform_data" "region_guard" {
  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, local.region)
      error_message = "Region ${local.region} is not in allowed_regions. This baseline only deploys to EU regions."
    }
  }
}

# Encryption key for the logs, with a policy that lets CloudTrail use it.
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
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowCloudTrailToEncryptLogs"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }

  statement {
    sid       = "AllowCloudTrailToDescribeKey"
    actions   = ["kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "logs" {
  description             = "Key for the ${local.bucket_name} audit log bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = var.tags

  depends_on = [terraform_data.region_guard]
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${local.bucket_name}"
  target_key_id = aws_kms_key.logs.key_id
}

# Private bucket that stores the logs.
resource "aws_s3_bucket" "logs" {
  #checkov:skip=CKV_AWS_144:Cross-region replication adds cost and may move data outside the EU. Optional extra, not part of the baseline.
  #checkov:skip=CKV2_AWS_62:Event notifications are not a security control for this baseline.
  #checkov:skip=CKV_AWS_18:This is the audit log bucket; logging it to itself would be circular. CloudTrail records API activity.
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags

  depends_on = [terraform_data.region_guard]
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.logs.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Deletes logs after the retention period so they are not kept forever.
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.logs]
}

# Lets CloudTrail (and only this trail) write logs, and refuses non-HTTPS requests.
data "aws_iam_policy_document" "bucket" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logs.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/AWSLogs/${local.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*",
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

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.bucket.json

  depends_on = [aws_s3_bucket_public_access_block.logs]
}

# The trail itself: records who did what in the account.
resource "aws_cloudtrail" "this" {
  #checkov:skip=CKV_AWS_252:SNS notifications on log delivery are optional and add moving parts. Not part of the lite baseline.
  #checkov:skip=CKV_AWS_67:Multi-region trails are not supported on the AWS Free plan; set is_multi_region_trail = true on a paid account.
  #checkov:skip=CKV2_AWS_10:CloudWatch Logs integration adds ongoing cost. Planned as an optional switch.
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.logs.id
  kms_key_id                    = aws_kms_key.logs.arn
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = var.is_multi_region_trail
  tags                          = var.tags

  depends_on = [aws_s3_bucket_policy.logs]
}
