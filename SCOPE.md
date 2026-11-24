# Scope

## Goal

A small set of secure-by-default AWS building blocks for EU regions, written in OpenTofu, with plain-English notes on how they relate to GDPR Article 32. This is a learning and portfolio project. It is not legal advice and it is not a compliance guarantee.

## Design decisions

- **OpenTofu, not Terraform.** OpenTofu is open source (MPL 2.0), so the code stays free to use and share.
- **EU regions only.** The region is a variable, and the modules refuse to plan outside a list of EU regions.
- **Wording.** This is a "GDPR-aligned technical baseline". It covers some technical measures only. Organisational duties (lawful basis, records, processor agreements) are outside the code.
- **Temporary credentials.** Sign in with `aws login`. Long-lived access keys are never used or stored.
- **Written reasons for every skipped check.** Scanner findings and decisions are recorded in `docs/scan-decisions.md`.

## What is in this repository

- `modules/secure-bucket`: private, encrypted S3 bucket with versioning, HTTPS only and a lifecycle rule
- `modules/audit-logging`: CloudTrail trail to an encrypted, private log bucket with a retention period
- `modules/budget-alarm`: monthly budget with email alerts
- `examples/`: working examples that use the modules
- `docs/`: architecture, Article 32 mapping and scan decisions

## Known limits

- Tested in a single AWS account on the Free plan, in eu-north-1 (Stockholm). Some features, such as multi-region trails and AWS Organizations, are not available on that plan.
- Not production hardened. Review everything before using it with real personal data.
- No pseudonymisation, full backup process or replication. See `docs/article-32-mapping.md` for the full list of gaps.

## Never in this repository

API keys, tokens, passwords, AWS credentials, state files, customer information or private datasets.

## Roadmap

1. Scan the live account with Prowler and record the results.
2. Add optional inputs for access logging and CloudWatch Logs.
3. Add more modules and examples.
