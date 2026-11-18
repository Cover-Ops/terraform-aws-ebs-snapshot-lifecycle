output "tags" {
  description = "The mandatory tags. Pass them to your provider's default_tags so everything you build carries them."
  value       = local.tags
}

output "policy_id" {
  description = "The Data Lifecycle Manager policy."
  value       = aws_dlm_lifecycle_policy.daily.id
}

output "opt_in_tag" {
  description = "Put this tag on a volume to snapshot it daily."
  value       = { (var.tag_key) = var.tag_value }
}
