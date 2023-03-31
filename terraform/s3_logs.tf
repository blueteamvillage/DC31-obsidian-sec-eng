#################### Logs Archive S3 ########################

resource "aws_s3_bucket" "logs_archive_raw" {
  bucket = "raw-logs-bucket"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_raw_logs"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_s3_bucket_acl" "raw_logs_private" {
  bucket = aws_s3_bucket.logs_archive_raw.id
  acl    = "private"
}

resource "aws_s3_bucket" "logs_archive_enriched" {
  bucket = "enriched-logs-bucket"

  tags = {
    Name    = "${var.PROJECT_PREFIX}_enriched_logs"
    Project = var.PROJECT_PREFIX
  }
}

resource "aws_s3_bucket_acl" "enriched_logs_private" {
  bucket = aws_s3_bucket.logs_archive_enriched.id
  acl    = "private"
}
