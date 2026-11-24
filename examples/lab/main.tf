variable "region" {
  description = "AWS region to deploy into. Must be an EU region."
  type        = string
  default     = "eu-north-1"
}

variable "budget_email" {
  description = "Email address for budget alerts. Set it with the TF_VAR_budget_email environment variable so it never goes into the repo."
  type        = string
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

module "audit_logging" {
  source = "../../modules/audit-logging"

  force_destroy = true # lab only: lets "tofu destroy" clean up fully

  tags = {
    Project = "aws-eu-baseline"
    Purpose = "lab-test"
  }
}

module "account_baseline" {
  source = "../../modules/account-baseline"
}

module "budget_alarm" {
  source = "../../modules/budget-alarm"

  email_addresses = [var.budget_email]
}

output "trail_arn" {
  value = module.audit_logging.trail_arn
}

output "log_bucket_name" {
  value = module.audit_logging.log_bucket_name
}
