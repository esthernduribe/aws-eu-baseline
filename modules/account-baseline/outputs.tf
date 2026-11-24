output "password_policy_minimum_length" {
  description = "Minimum IAM password length that is enforced."
  value       = aws_iam_account_password_policy.this.minimum_password_length
}
