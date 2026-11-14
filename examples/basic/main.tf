variable "region" {
  description = "AWS region to deploy into. Must be an EU region."
  type        = string
  default     = "eu-north-1"
}

provider "aws" {
  region = var.region
  # Credentials come from the AWS_PROFILE environment variable (see README).
}

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}

module "secure_bucket" {
  source = "../../modules/secure-bucket"

  # Bucket names must be unique across all of AWS, so we add the account number.
  bucket_name   = "aws-eu-baseline-demo-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # lab only: lets "tofu destroy" clean up fully

  tags = {
    Project = "aws-eu-baseline"
    Purpose = "lab-test"
  }
}

output "bucket_name" {
  value = module.secure_bucket.bucket_name
}

output "kms_key_arn" {
  value = module.secure_bucket.kms_key_arn
}
