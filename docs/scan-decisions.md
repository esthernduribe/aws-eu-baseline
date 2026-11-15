# Scan decisions

This file records what each security scanner flagged and what we did about it.
It is part of the evidence for the Article 32 mapping. It is not legal advice.

## Checkov (static scan of the OpenTofu code), 15 Nov 2026

First run: 70 passed, 14 failed.

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

Skips are written next to the resource in the code, so anyone reading the code sees the reason.

## Prowler (live account scan)

To be added after the scan.
