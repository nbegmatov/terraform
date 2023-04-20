terraform {
  required_version = ">= 1.0"
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "s3-backend" {
  count  = local.enabled
  bucket = "${var.org}-${var.namespace}-tf-state-bucket"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(local.common_tags, { "Name" = "${var.org}-${var.namespace}-ft-state" })
}

resource "aws_s3_bucket_public_access_block" "block" {
  count  = local.enabled
  bucket = aws_s3_bucket.s3-backend[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
