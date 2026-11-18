# CoverOps Marketplace kit: EBS snapshot lifecycle.
# Daily snapshots of the volumes you tag, keeping only the last N, with AWS Data Lifecycle Manager.
# Snapshots made any other way are never touched. Apache 2.0.

locals {
  tags = merge(var.extra_tags, {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCentre  = var.cost_centre
    ManagedBy   = "terraform"
    Kit         = "coverops/aws-ebs-snapshot-lifecycle"
  })
  name = "${var.project}-${var.environment}-snapshots"
}

data "aws_partition" "this" {}

data "aws_iam_policy_document" "dlm_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dlm" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.dlm_trust.json
  tags               = local.tags
}

# AWS's own policy for DLM: create, tag and delete EBS snapshots, nothing else.
resource "aws_iam_role_policy_attachment" "dlm" {
  role       = aws_iam_role.dlm.name
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

resource "aws_dlm_lifecycle_policy" "daily" {
  # DLM descriptions allow only letters, digits, spaces, hyphens and underscores.
  description        = "${local.name} daily keep ${var.retain_count}"
  execution_role_arn = aws_iam_role.dlm.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]
    target_tags    = { (var.tag_key) = var.tag_value }

    schedule {
      name      = "daily-keep-${var.retain_count}"
      copy_tags = true

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = [var.time_utc]
      }

      retain_rule {
        count = var.retain_count
      }

      tags_to_add = { SnapshotCreator = "coverops/aws-ebs-snapshot-lifecycle" }
    }
  }

  tags = local.tags

  depends_on = [aws_iam_role_policy_attachment.dlm]
}
