# Scope and decisions

Working title: aws-eu-baseline. Branding comes later.

## Decisions made

- **Tooling:** OpenTofu, not Terraform. OpenTofu uses the MPL 2.0 licence, which is simpler for distributing modules.
- **Region:** the code takes the region as a variable and only allows EU regions. The lab account is fixed to eu-north-1 (Stockholm), so that is the default for testing.
- **Claims:** the project says "GDPR-aligned technical baseline", never "GDPR compliant".
- **Credentials:** temporary credentials from `aws login`, no long-lived keys in files.

## Known limits of the lab account

The lab account uses AWS's new sign-up experience on the Free plan. S3, KMS, CloudTrail, Config, IAM and Budgets are available. GuardDuty, Security Hub, Control Tower, Organizations and Identity Center are not, so the paid pack cannot be fully tested here without activating advanced features.
- **Repository:** private while in development. A separate public repo will hold the free "lite" version.

## Lite version (public later)

1. EU region guardrail
2. Encrypted, private storage module (KMS, block public access, TLS only)
3. CloudTrail logging to an encrypted bucket
4. Budget alarm
5. Article 32 mapping notes and an architecture diagram
6. Checkov and Prowler scan results

## Paid pack (private, later)

- Multi-account setup
- Security Hub, GuardDuty and Config
- IAM Identity Center permission sets
- Backup and retention rules
- Records-of-processing and processor-agreement checklists
- Setup support

## Never goes in any repo

API keys, tokens, passwords, AWS credentials, state files, customer information, private datasets.

## Stages

1. Repo, README, .gitignore and scope (this stage)
2. Safe AWS account setup and local tools
3. First module: region guardrail and encrypted storage
4. Audit logging and budget alarm
5. Scanning and tests
6. Documentation and diagrams
7. Public lite release
