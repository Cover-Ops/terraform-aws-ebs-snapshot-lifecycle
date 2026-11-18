# EBS snapshot lifecycle

A CoverOps Marketplace kit. Snapshots taken by hand or by scripts tend to pile up for years. This kit has AWS Data Lifecycle Manager take one snapshot a day of each volume you tag, and keep only the last 7. Terraform ≥ 1.6 or OpenTofu ≥ 1.6, AWS provider 6.x. Apache 2.0.

> Status: **v0.1.0, tested on 2026-11-18**: applied, re-planned with no changes and destroyed on a sandbox AWS account (ap-south-1), nothing left behind. Run `terraform plan` before you apply it to your account.

## What it creates

| Resource | Why | Cost |
|---|---|---|
| Data Lifecycle Manager policy: daily at 02:00 IST, keep 7 | Every volume tagged Backup=daily gets a snapshot; the 8th oldest is deleted | Free (you pay for the snapshots kept) |
| IAM role for Data Lifecycle Manager with AWS's own policy | Lets DLM create and delete only snapshots | Free |

**Estimated monthly cost: ₹0** (estimate, at AWS list prices). DLM is free. You pay for the snapshots it keeps; they are incremental, so 7 dailies cost little more than one full copy.

## Mandatory tags
The kit's `tags` output is `Project`, `Environment`, `Owner`, `CostCentre`, `ManagedBy` and `Kit`. Put the same tags in your provider's `default_tags` (see the example) so everything you create carries them. The CoverOps Platform reads these tags to say who owns each rupee.

## Use

```hcl
module "snapshots" {
  source = "github.com/Cover-Ops/terraform-aws-ebs-snapshot-lifecycle?ref=v0.1.0"

  project     = "acme"
  environment = "production"
  owner       = "platform@acme.example"
}

# Then tag each volume to back up: Backup = "daily".
```

Full example: [`examples/basic`](examples/basic).

## Inputs

| Name | Description | Default |
|---|---|---|
| `project` | Short name of the product or company, used in names and the Project tag (lowercase, digits, hyphens). | required |
| `environment` | Which environment this is: production, staging or development. | required |
| `owner` | Who answers for spend on what this kit manages: a team or a person's email. Goes in the Owner tag. | required |
| `cost_centre` | Cost centre or budget line for the CostCentre tag, e.g. engineering. | `engineering` |
| `tag_key` | Tag key that opts a volume in to scheduled snapshots. | `Backup` |
| `tag_value` | Tag value that opts a volume in, e.g. Backup=daily. | `daily` |
| `time_utc` | When the daily snapshot starts, in UTC (HH:MM). 20:30 UTC is 02:00 IST. | `20:30` |
| `retain_count` | How many daily snapshots to keep per volume. Older ones made by this policy are deleted. | `7` |
| `extra_tags` | More tags to add to everything this kit creates. | `{}` |

## Outputs
`tags`, `policy_id`, `opt_in_tag`.

## Good to know
- Only volumes with the opt-in tag are snapshotted. Tag the volume, not the instance.
- DLM deletes only the snapshots this policy made. Older snapshots you already have stay: the CoverOps Platform and the idle-report kit list them.
- Snapshots are incremental: each one stores only the blocks that changed since the last.
- This is not a full backup plan: there is no copy to another region or account. Use AWS Backup for that.

## Support
Open an issue on GitHub. Want CoverOps engineers to apply it for you? See the setup service on marketplace.coverops.dev.
