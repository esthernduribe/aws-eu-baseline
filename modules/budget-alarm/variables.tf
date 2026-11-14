variable "budget_name" {
  description = "Name of the budget."
  type        = string
  default     = "aws-eu-baseline-monthly"
}

variable "limit_usd" {
  description = "Monthly spending limit in US dollars."
  type        = number
  default     = 5

  validation {
    condition     = var.limit_usd > 0
    error_message = "limit_usd must be greater than 0."
  }
}

variable "email_addresses" {
  description = "Email addresses that receive the alerts."
  type        = list(string)

  validation {
    condition     = length(var.email_addresses) > 0
    error_message = "Provide at least one email address."
  }
}

variable "include_credits" {
  description = "If true, credits are subtracted before the budget is checked, so alerts only fire once credits run out. Keep false to be warned about real usage."
  type        = bool
  default     = false
}
