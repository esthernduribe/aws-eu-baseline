variable "bucket_name" {
  description = "Globally unique name for the S3 bucket (3-63 lowercase letters, numbers and hyphens)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters: lowercase letters, numbers and hyphens, starting and ending with a letter or number."
  }
}

variable "allowed_regions" {
  description = "Regions this module may be deployed into. Defaults to EU regions only."
  type        = list(string)
  default = [
    "eu-west-1",    # Ireland
    "eu-west-3",    # Paris
    "eu-central-1", # Frankfurt
    "eu-north-1",   # Stockholm
    "eu-south-1",   # Milan
    "eu-south-2",   # Spain
    "eu-central-2", # Zurich
  ]
}

variable "kms_deletion_window_in_days" {
  description = "Days AWS waits before deleting the KMS key after it is scheduled for deletion (7-30)."
  type        = number
  default     = 7

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days must be between 7 and 30."
  }
}

variable "force_destroy" {
  description = "If true, tofu destroy also deletes every object in the bucket. Keep false for real data."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags added to every resource that supports them."
  type        = map(string)
  default     = {}
}
