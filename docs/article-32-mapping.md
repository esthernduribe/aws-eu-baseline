# GDPR Article 32 mapping

**This is a technical mapping, not legal advice, and using this code does not make an organisation GDPR compliant.**
Article 32 asks for "appropriate technical and organisational measures". This repo only covers some technical ones, for storage and logging in AWS. Organisational duties, such as choosing a lawful basis, keeping records of processing and signing processor agreements, are outside the code.

Status key: **Built** (in the modules and tested in the lab), **Partly**, **Not covered**.

## Article 32(1)

| Article 32 wording | What the baseline does | Status |
|---|---|---|
| (a) encryption of personal data | Buckets encrypted at rest with a KMS key (automatic rotation on). Requests without HTTPS are refused. | Built |
| (a) pseudonymisation | Not covered. This is a data design choice, not infrastructure. | Not covered |
| (b) ongoing confidentiality | All public access blocked on both buckets and, with the account-baseline module, across the whole account for S3. ACLs disabled so only policies control access. Explicit KMS key policy. Strong IAM password policy. | Built |
| (b) ongoing integrity | CloudTrail log file validation shows whether logs were altered. Bucket versioning keeps earlier versions of objects. | Built |
| (b) ongoing availability and resilience | Versioning helps recover from deletion or overwrite. No replication or multi-region setup. | Partly |
| (c) restore availability and access after an incident | Versioning allows recovery of earlier object versions. No full backup or restore process. | Partly |
| (d) regular testing of measures | Checkov scans the code (81 passed, 0 failed, 15 skipped with written reasons). Prowler scanned the live lab account: 50 passed and 19 failed after fixes, with every remaining finding explained in `scan-decisions.md`. | Partly |

## Related articles

| Article | What the baseline does | Status |
|---|---|---|
| 5(1)(e) storage limitation | Audit logs expire after a retention period (default 365 days). Old object versions expire after 90 days. Both settings can be changed. | Partly |
| 5(2) and 24 accountability | CloudTrail records who did what in the account. `scan-decisions.md` records scanner findings and decisions. | Partly |
| 44 and following, transfers | An EU-only region guard stops deployment outside the listed EU regions. It does not control where data comes from or who can access it. | Partly |

## Not covered by this repo

- Lawful basis, privacy notices, records of processing, data protection impact assessments
- Processor agreements with AWS or other suppliers
- Access reviews, staff training and incident response
- Data subject requests (access, erasure and so on)
- Pseudonymisation and data minimisation in your own applications

## Sources

- GDPR Article 32 (security of processing): https://gdpr-info.eu/art-32-gdpr/
- Irish Data Protection Commission guidance on cloud computing
