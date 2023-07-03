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

####################################### insider threat bucket #######################################
resource "aws_s3_bucket_policy" "insider_threat" {
  bucket = aws_s3_bucket.insider_threat.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Principal" : "*",
        "Action" : ["s3:Get*", "s3:List*"],
        "Resource" : [
          "${aws_s3_bucket.insider_threat.arn}/*"
        ],
        "Effect" : "Allow",
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : "${module.vpc.nat_public_ips[0]}/32"
          }
        }
      }
    ]
  })
}


resource "aws_s3_bucket" "insider_threat" {
  bucket = "ot-protocol-support"

  tags = {
    Name    = "ot-protocol-support"
    Project = var.PROJECT_PREFIX
  }
}


####################################### Velociraptor S3 bucket #######################################
resource "aws_s3_bucket" "raptor_uploader" {
  bucket = "${lower(replace(var.PROJECT_PREFIX, "_", "-"))}-raptor-${random_string.bucket_suffix.result}"

  tags = {
    Name    = "${lower(replace(var.PROJECT_PREFIX, "_", "-"))}-raptor-bucket"
    Project = var.PROJECT_PREFIX
  }
}
