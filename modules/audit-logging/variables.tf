variable "name_prefix" {
  description = "Prefix for resource names, for example aws-eu-baseline."
  type        = string
  default     = "aws-eu-baseline"
}

variable "trail_name" {
  description = "Name of the CloudTrail trail."
  type        = string
  default     = "baseline-audit-trail"
}

variable "allowed_regions" {
  description = "Regions this module may be deployed into. Defaults to EU regions only."
  type        = list(string)
  default = [
    "eu-west-1",
    "eu-west-3",
    "eu-central-1",
    "eu-north-1",
    "eu-south-1",
    "eu-south-2",
    "eu-central-2",
  ]
}

variable "is_multi_region_trail" {
  description = "Record events from all regions. Keep false on the AWS Free plan, which does not support multi-region trails."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Days to keep audit logs before they are deleted. Choose a period you can justify in your own records."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 30
    error_message = "log_retention_days must be at least 30."
  }
}

variable "force_destroy" {
  description = "If true, tofu destroy also deletes every log in the bucket. Keep false for real data."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags added to every resource that supports them."
  type        = map(string)
  default     = {}
}
