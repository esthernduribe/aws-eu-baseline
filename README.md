# aws-eu-baseline

A starter baseline for running personal data workloads on AWS in the EU. Secure defaults for a small team, written in OpenTofu, with plain-English notes on which GDPR Article 32 measures each piece supports.

**Status:** early planning. Nothing here is usable yet.

## What this is

- Reusable infrastructure code that sets safe defaults: EU-only regions, encryption, private storage, audit logging and budget alerts.
- Short documentation mapping each control to the Article 32 security measure it supports.
- Scan results from open source tools (Checkov, Prowler) so you can see what was tested.

## What this is not

- Legal advice.
- A guarantee of GDPR compliance. GDPR also covers things infrastructure cannot, like lawful basis, records of processing and contracts with processors. This project is a technical baseline only.

## Planned scope (v0.1 lite)

- EU region guardrail
- Encrypted, private storage module
- CloudTrail audit logging
- Budget alarm
- Documentation and architecture diagram

## Tooling

- OpenTofu
- AWS (EU regions only; tested in eu-north-1, Stockholm)
- Checkov and Prowler for scanning

## Repository layout

Will be added as the code is written. See SCOPE.md for the plan.

## Licence

To be decided before the first public release.
