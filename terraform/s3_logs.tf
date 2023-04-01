#################### Logs Archive S3 ########################
# https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/s3/ignore-public-acls/
# https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/s3/block-public-acls/
# https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/s3/enable-bucket-encryption/
# https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/s3/encryption-customer-key/
# https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/s3/enable-bucket-logging/
# https://aquasecurity.github.io/tfsec/v1.28.1/checks/aws/s3/enable-versioning/

resource "aws_kms_key" "logs_s3_key" {
  enable_key_rotation = true
}

#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "logs_infra" {
  bucket = "infra-logs-bucket"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # kms_master_key_id = "arn"
        kms_master_key_id = aws_kms_key.logs_s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_infra_logs"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_s3_bucket_acl" "infra_logs_private" {
  bucket = aws_s3_bucket.logs_infra.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "logs_infra_block_public" {
  bucket                  = aws_s3_bucket.logs_infra.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket" "logs_archive_raw" {
  bucket = "raw-logs-bucket"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "infra-logs-bucket"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # kms_master_key_id = "arn"
        kms_master_key_id = aws_kms_key.logs_s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_raw_logs"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_s3_bucket_acl" "raw_logs_private" {
  bucket = aws_s3_bucket.logs_archive_raw.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "logs_archive_raw_block_public" {
  bucket                  = aws_s3_bucket.logs_archive_raw.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket" "logs_archive_enriched" {
  bucket = "enriched-logs-bucket"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "infra-logs-bucket"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # kms_master_key_id = "arn"
        kms_master_key_id = aws_kms_key.logs_s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name    = "${var.PROJECT_PREFIX}_enriched_logs"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_s3_bucket_acl" "enriched_logs_private" {
  bucket = aws_s3_bucket.logs_archive_enriched.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "enriched_logs_privateblock_public" {
  bucket                  = aws_s3_bucket.logs_archive_enriched.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
