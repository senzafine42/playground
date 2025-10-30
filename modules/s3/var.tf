variable "bucket_base_name" {
  description = "Base name to prefix the bucket (lowercase letters, numbers, and hyphens)."
  type        = string
}

variable "region" {
  description = "AWS region for the bucket (e.g., us-east-2). Used in name; provider must target this region."
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 versioning."
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Enable S3 public access block on the bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete non-empty buckets."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
