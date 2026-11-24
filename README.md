# aws-eu-baseline

OpenTofu code for a GDPR-aligned technical baseline on AWS, using EU regions only.

**Status:** early development. The first four modules work in a lab account (tested in eu-north-1, Stockholm). Not ready for production use.

## What this is, and is not

- A small set of secure-by-default AWS building blocks, with plain-English notes on how they relate to GDPR Article 32.
- Scanned with Checkov (code) and Prowler (live lab account), with every finding and decision written down in `docs/scan-decisions.md`.
- **Not legal advice**, and not a guarantee of GDPR compliance. It covers some technical measures only. See `docs/article-32-mapping.md` for what is and is not covered.

## Modules

| Module | What it builds |
|---|---|
| `modules/secure-bucket` | Private S3 bucket: KMS encryption, blocked public access, HTTPS only, versioning, lifecycle rule, EU region guard |
| `modules/audit-logging` | CloudTrail trail writing to an encrypted, private log bucket with log file validation and a retention period |
| `modules/account-baseline` | IAM password policy and an account-wide S3 public access block |
| `modules/budget-alarm` | Monthly budget that emails you at 80% of actual spend and 100% of forecast spend |

## Repository layout

```
modules/     reusable building blocks
examples/    working examples (basic = bucket, lab = logging + budget)
docs/        architecture, Article 32 mapping, scan decisions
SCOPE.md     decisions and the plan
```

## Quick start

You need OpenTofu, AWS CLI v2 and Git. Sign in with `aws login`, then:

```
git clone https://github.com/esthernduribe/aws-eu-baseline.git
cd aws-eu-baseline/examples/basic
tofu init
tofu plan
```

Full steps, including how to remove everything afterwards, are in [docs/quickstart.md](docs/quickstart.md).

## Documentation

- [Quick start](docs/quickstart.md)
- [Architecture](docs/architecture.md)
- [Article 32 mapping](docs/article-32-mapping.md)
- [Scan decisions](docs/scan-decisions.md)

## Tooling

OpenTofu, the AWS provider (6.x), Checkov (code scan) and Prowler (live account scan). EU regions only.

## Secrets

Never commit credentials, `.env` files or state files. The `.gitignore` already blocks them. Sign in with temporary credentials (`aws login`), not long-lived keys.

## Licence

MIT. See [LICENSE](LICENSE).
