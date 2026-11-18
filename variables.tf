variable "project" {
  description = "Short name of the product or company, used in names and the Project tag (lowercase, digits, hyphens)."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.project))
    error_message = "Use 2-31 characters: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Which environment this is: production, staging or development."
  type        = string
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Use production, staging or development."
  }
}

variable "owner" {
  description = "Who answers for spend on what this kit manages: a team or a person's email. Goes in the Owner tag."
  type        = string
}

variable "cost_centre" {
  description = "Cost centre or budget line for the CostCentre tag, e.g. engineering."
  type        = string
  default     = "engineering"
}

variable "tag_key" {
  description = "Tag key that opts a volume in to scheduled snapshots."
  type        = string
  default     = "Backup"
}

variable "tag_value" {
  description = "Tag value that opts a volume in, e.g. Backup=daily."
  type        = string
  default     = "daily"
}

variable "time_utc" {
  description = "When the daily snapshot starts, in UTC (HH:MM). 20:30 UTC is 02:00 IST."
  type        = string
  default     = "20:30"
  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.time_utc))
    error_message = "Use HH:MM, 24-hour, UTC."
  }
}

variable "retain_count" {
  description = "How many daily snapshots to keep per volume. Older ones made by this policy are deleted."
  type        = number
  default     = 7
  validation {
    condition     = var.retain_count >= 1 && var.retain_count <= 1000
    error_message = "Keep between 1 and 1000 snapshots."
  }
}

variable "extra_tags" {
  description = "More tags to add to everything this kit creates."
  type        = map(string)
  default     = {}
}
