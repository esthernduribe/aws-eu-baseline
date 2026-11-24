variable "minimum_password_length" {
  description = "Minimum length for IAM user passwords."
  type        = number
  default     = 14

  validation {
    condition     = var.minimum_password_length >= 14
    error_message = "minimum_password_length must be at least 14."
  }
}

variable "max_password_age_days" {
  description = "Days before an IAM user password must be changed."
  type        = number
  default     = 90

  validation {
    condition     = var.max_password_age_days >= 1 && var.max_password_age_days <= 90
    error_message = "max_password_age_days must be between 1 and 90."
  }
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords that cannot be reused."
  type        = number
  default     = 24

  validation {
    condition     = var.password_reuse_prevention >= 24 && var.password_reuse_prevention <= 24
    error_message = "password_reuse_prevention must be 24 (the maximum AWS allows)."
  }
}
