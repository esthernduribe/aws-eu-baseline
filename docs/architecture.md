# Architecture

This is what the baseline builds in one AWS account, in one EU region.
The lab account runs in eu-north-1 (Stockholm).

```mermaid
flowchart LR
    user["You (tofu apply)"] --> guard{"Region guard:<br/>EU regions only"}
    guard --> sb
    guard --> al
    guard --> ba

    subgraph sb["Module: secure-bucket"]
        kmsA["KMS key<br/>rotation on"] --> bucketA["Private S3 bucket<br/>encrypted, versioned,<br/>HTTPS only, lifecycle rule"]
    end

    subgraph al["Module: audit-logging"]
        trail["CloudTrail trail<br/>log file validation"] --> logs["Private log bucket<br/>encrypted, versioned,<br/>logs expire after 365 days"]
        kmsB["KMS key<br/>rotation on"] --> logs
    end

    subgraph ba["Module: budget-alarm"]
        budget["Monthly budget<br/>email at 80% actual<br/>and 100% forecast"]
    end

    api["Activity in the account<br/>(API calls, sign-ins)"] --> trail
```

## Notes

- Everything is created with OpenTofu, so it can be reviewed, repeated and removed.
- The region guard stops a plan if the region is not on the EU list.
- Each module can be used on its own.
- Left out on purpose (see `scan-decisions.md`): cross-region replication, S3 access logging, CloudWatch Logs, SNS notifications, multi-region trail on the Free plan.
