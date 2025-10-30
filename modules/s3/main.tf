terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Random 6-digit, min 000042
resource "random_integer" "suffix" {
  min = 42
  max = 999999
}

locals {
  # Ensure region is lowercase and safe for names
  region_lower   = lower(var.region)
  suffix_padded  = format("%06d", random_integer.suffix.result)
  bucket_name    = "${var.bucket_base_name}-${local.region_lower}-${local.suffix_padded}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    "Name"   = local.bucket_name
    "Region" = local.region_lower
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
