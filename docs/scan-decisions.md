# Scan decisions

This file records what each security scanner flagged and what we did about it.
It is part of the evidence for the Article 32 mapping. It is not legal advice.

## Checkov (static scan of the OpenTofu code), 15 Nov 2026

First run: 70 passed, 14 failed.
After the fixes below: 81 passed, 0 failed, 15 skipped (each skip is written next to the code with its reason).

| Check | Finding | Decision | Reason |
|---|---|---|---|
| CKV2_AWS_64 | secure-bucket KMS key has no explicit policy | Fixed | Added an explicit key policy |
| CKV2_AWS_61 | secure-bucket has no lifecycle configuration | Fixed | Old versions expire after 90 days (adjustable); storage is not kept forever |
| CKV_AWS_109, CKV_AWS_111, CKV_AWS_356 | KMS key policy uses "*" as resource | Skipped (inline) | In a KMS key policy "*" means this key only. This is the standard AWS pattern |
| CKV_AWS_144 | No cross-region replication | Skipped (inline) | Adds cost and could move data outside the EU. Optional extra |
| CKV2_AWS_62 | No S3 event notifications | Skipped (inline) | Not a security control for this baseline |
| CKV_AWS_18 | No S3 access logging | Skipped (inline) | Audit bucket would log to itself. Optional input planned for secure-bucket |
| CKV_AWS_252 | CloudTrail has no SNS topic | Skipped (inline) | Optional, not in lite baseline |
| CKV_AWS_67 | CloudTrail not multi-region | Skipped (inline) | Not supported on the AWS Free plan. Set is_multi_region_trail = true on a paid account |
| CKV2_AWS_10 | CloudTrail not sent to CloudWatch Logs | Skipped (inline) | Adds ongoing cost. Planned as an optional switch |

## Prowler (scan of the live lab account), 24 Nov 2026

Scanned services: S3, CloudTrail, KMS and IAM, in eu-north-1. The secure-bucket example had already been removed, so the only S3 bucket scanned was the audit log bucket.

- First scan: 97 checks run, 42 passed, 27 failed.
- After adding `modules/account-baseline`: 97 checks run, 50 passed, 19 failed.

### Fixed (8 findings)

| Check | Fix |
|---|---|
| s3_account_level_public_access_blocks (high) | Account-wide S3 public access block added |
| iam_password_policy_* (7 checks: length 14, upper case, lower case, number, symbol, reuse 24, 90-day expiry) | IAM password policy added |

### Accepted, account level (8 findings)

| Check | Reason |
|---|---|
| iam_aws_attached_policy_no_administrative_privileges (critical) | AdministratorAccess is attached only to AccountFullAccessRole, a role AWS creates for the account owner's sign-in. No IAM users exist (checked 24 Nov 2026). Not changed, because removing it could lock the owner out |
| iam_role_cross_service_confused_deputy_prevention (high) | Same AWS-created role, not managed by this repo |
| iam_root_credentials_management_enabled (high) | Account-level AWS setting outside this repo. To be reviewed |
| iam_role_access_not_stale_to_bedrock (3 roles, medium) | AWS-created roles, not managed by this repo. Bedrock is not used |
| iam_securityaudit_role_created, iam_support_role_created (low) | Optional role setup, not part of the lite baseline |

### Accepted, optional extras (11 findings)

| Check | Reason |
|---|---|
| cloudtrail_bucket_requires_mfa_delete, s3_bucket_no_mfa_delete | MFA delete cannot be set up with infrastructure code in a practical way |
| cloudtrail_logs_s3_bucket_access_logging_enabled, s3_bucket_server_access_logging_enabled | The audit bucket would log to itself. CloudTrail records API activity |
| cloudtrail_cloudwatch_logging_enabled | Adds ongoing cost. Planned as an optional switch |
| cloudtrail_insights_exist | Extra cost, not needed for the baseline |
| cloudtrail_s3_dataevents_read_enabled, cloudtrail_s3_dataevents_write_enabled | Extra cost. Can be enabled per bucket when needed |
| s3_bucket_cross_region_replication | Adds cost and may move data outside the EU |
| s3_bucket_event_notifications_enabled | Not a security control for this baseline |
| s3_bucket_object_lock | Would block deletion, which does not suit a baseline meant to be torn down and rebuilt |

This is a snapshot of one lab account at one point in time, not a certification.
