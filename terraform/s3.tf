resource "random_string" "bucket_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "project_bucket" {
  bucket = "${lower(replace(var.PROJECT_PREFIX, "_", "-"))}-${random_string.bucket_suffix.result}"

  tags = {
    Name    = "${lower(replace(var.PROJECT_PREFIX, "_", "-"))}-s3-project-bucket"
    Project = var.PROJECT_PREFIX
  }
}

locals {
  s3_bucket_project_folders = [
    "reverse_engineering",
    "threat_hunting",
    "incident_response",
    "foreneics",
    "foreneics/memory_dumps",
    "foreneics/artifacts",
    "threat_intel",
    "red_team",
    "sec_engineering",
    "detection_engineering",
    "snaphosts",
    "logs",
    "pcaps",
  ]
}

resource "aws_s3_bucket_object" "project_folders" {
  for_each = { for idx, val in local.s3_bucket_project_folders : idx => val }

  bucket = aws_s3_bucket.project_bucket.id
  acl    = "private"
  key    = "${each.value}/"
  source = "/dev/null"
}
