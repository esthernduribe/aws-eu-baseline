# Quick start

This walks you through trying the `secure-bucket` example in your own AWS account, then removing it again. It takes about 15 minutes. A free lab account is fine. Do not use an account that holds real personal data while you are learning.

## What you need

- An AWS account, and permission to create S3 buckets and KMS keys in it
- [OpenTofu](https://opentofu.org/docs/intro/install/) (tested with 1.13)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), version 2.32 or newer (needed for `aws login`)
- [Git](https://git-scm.com/downloads)

Check them:

```
tofu --version
aws --version
git --version
```

## 1. Get the code

```
git clone https://github.com/esthernduribe/aws-eu-baseline.git
cd aws-eu-baseline
```

## 2. Sign in to AWS with temporary credentials

This repo never uses long-lived access keys.

```
aws login --profile baseline --region eu-north-1
```

A browser tab opens. Sign in and approve. Then tell your terminal to use that profile.

Windows PowerShell:

```
$env:AWS_PROFILE = "baseline"
$env:AWS_REGION = "eu-north-1"
```

macOS or Linux:

```
export AWS_PROFILE=baseline
export AWS_REGION=eu-north-1
```

Check it worked:

```
aws sts get-caller-identity
```

You should see your account number.

## 3. Try the secure bucket example

```
cd examples/basic
tofu init
tofu plan
```

The plan lists about nine resources and creates nothing. If it looks right:

```
tofu apply
```

Type `yes` when asked. When it finishes, check the bucket:

```
aws s3api get-public-access-block --bucket <bucket name from the output>
aws s3api get-bucket-encryption --bucket <bucket name from the output>
```

You should see all four public access settings as `true`, and encryption with `aws:kms`.

## 4. Remove it

```
tofu destroy
```

Type `yes`. Everything the example created is deleted. The KMS key stays in "pending deletion" for 7 days, which is normal and free.

## Use a module in your own code

```hcl
module "secure_bucket" {
  source      = "git::https://github.com/esthernduribe/aws-eu-baseline.git//modules/secure-bucket?ref=main"
  bucket_name = "my-unique-bucket-name"
}
```

Bucket names must be unique across all of AWS. For anything real, pin to a specific commit instead of `main`.

## The lab example (logging, budget alarm and account settings)

`examples/lab` builds the audit logging, the budget alarm and the account baseline. **The account baseline changes account-wide settings**: the IAM password policy and the S3 public access block for every bucket in the account. Only run it in an account where you are happy with that.

```
cd examples/lab
tofu init
$env:TF_VAR_budget_email = "you@example.com"   # PowerShell
tofu plan
```

On macOS or Linux, use `export TF_VAR_budget_email=you@example.com`.

## Common errors

| Message | What to do |
|---|---|
| `No valid credential sources found` or `token expired` | Run `aws login --profile baseline --region eu-north-1` again, then set the two environment variables again |
| `You must specify a region` (from the AWS CLI) | Set `AWS_REGION` as shown in step 2 |
| `Region ... is not in allowed_regions` | The modules only deploy to EU regions. Use an EU region |
| `BucketAlreadyExists` | Bucket names are global. Pick a different name |
| `No value for required variable budget_email` | Set `TF_VAR_budget_email` in the same terminal window |

## Cost and safety

- The bucket example costs close to nothing while it is empty. Destroy it when you are finished.
- The modules are not production hardened. Read the code and the limits in `docs/article-32-mapping.md` before using them with real personal data.
- This is a technical baseline. It is not legal advice and does not make anyone GDPR compliant.
