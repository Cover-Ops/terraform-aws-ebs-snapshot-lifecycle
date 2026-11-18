# Daily snapshots, last 7 kept, for every volume tagged Backup=daily in a startup's production account.
locals {
  project     = "acme"
  environment = "production"
  owner       = "platform@acme.example"
}

provider "aws" {
  region = "ap-south-2"

  # The same mandatory tags on everything else you create with this provider.
  default_tags {
    tags = {
      Project     = local.project
      Environment = local.environment
      Owner       = local.owner
      CostCentre  = "engineering"
      ManagedBy   = "terraform"
    }
  }
}

module "snapshots" {
  source = "../.."
  # After publishing: source = "github.com/Cover-Ops/terraform-aws-ebs-snapshot-lifecycle?ref=v0.1.0"

  project     = local.project
  environment = local.environment
  owner       = local.owner
}
