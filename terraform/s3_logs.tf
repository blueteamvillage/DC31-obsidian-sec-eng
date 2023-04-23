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
  bucket = replace(lower("${var.PROJECT_PREFIX}-infra-logs-bucket"), "_", "-")

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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# resource "aws_s3_bucket_versioning" "logs_infra_versioning" {
#   bucket = aws_s3_bucket.logs_infra.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

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

#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "logs_archive_raw" {
  bucket = replace(lower("${var.PROJECT_PREFIX}-raw-logs-bucket"), "_", "-")

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

# resource "aws_s3_bucket_versioning" "logs_archive_raw_versioning" {
#   bucket = aws_s3_bucket.logs_archive_raw.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging
# resource "aws_s3_bucket_logging" "logs_archive_raw_logging" {
#   bucket = aws_s3_bucket.logs_archive_raw.id
#
#   target_bucket = aws_s3_bucket.logs_infra.id
#   target_prefix = "logs/s3_logs_archive_raw_logging/"
# }

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

#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "logs_archive_enriched" {
  bucket = replace(lower("${var.PROJECT_PREFIX}-enriched-logs-bucket"), "_", "-")

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

# resource "aws_s3_bucket_versioning" "logs_archive_enriched_versioning" {
#   bucket = aws_s3_bucket.logs_archive_enriched.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_logging" "logs_archive_enriched_logging" {
#   bucket = aws_s3_bucket.logs_archive_enriched.id
#
#   target_bucket = aws_s3_bucket.logs_infra.id
#   target_prefix = "logs/s3_logs_archive_enriched/"
# }

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

#################### Logs Archive IAM ########################
# https://skundunotes.com/2021/11/16/attach-iam-role-to-aws-ec2-instance-using-terraform/
# https://github.com/kunduso/ec2-userdata-terraform/tree/add-iam-role
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-policies-s3.html#iam-policy-ex4
# https://marcqualie.com/2017/05/write-only-s3-permissions
resource "aws_iam_policy" "writeonly_logs_policy" {
  name        = "${var.PROJECT_PREFIX}_writeonly_logs_policy"
  path        = "/"
  description = "Policy to provide write-only permission to S3"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "CriblWriteBucketPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "${aws_s3_bucket.logs_infra.arn}",
          "${aws_s3_bucket.logs_archive_raw.arn}",
          "${aws_s3_bucket.logs_archive_enriched.arn}",
        ]
      },
      {
        "Sid" : "CriblWriteBaseObjectReadPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAcl",
        ],
        "Resource" : [
          "${aws_s3_bucket.logs_infra.arn}/*",
          "${aws_s3_bucket.logs_archive_raw.arn}/*",
          "${aws_s3_bucket.logs_archive_enriched.arn}/*",
        ]
      },
      {
        "Sid" : "CriblWriteOnlyPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : [
          "${aws_s3_bucket.logs_infra.arn}/*",
          "${aws_s3_bucket.logs_archive_raw.arn}/*",
          "${aws_s3_bucket.logs_archive_enriched.arn}/*",
        ]
      }
    ]
  })
}

# Create a role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "writeonly_logs_role" {
  name = "${var.PROJECT_PREFIX}_writeonly_logs_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        "Sid" : "",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : "arn:aws:iam::106453756913:role/${var.PROJECT_PREFIX}_writeonly_logs_role",
        },
        "Effect" : "Allow"
      },
    ]
  })
}

# Attach role to policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_policy_attachment" "writeonly_logs_policy_role" {
  name       = "writeonly_logs_attachment"
  roles      = [aws_iam_role.writeonly_logs_role.name]
  policy_arn = aws_iam_policy.writeonly_logs_policy.arn
}

# Attach role to an instance profile
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "writeonly_logs_profile" {
  name = "writeonly_logs_profile"
  role = aws_iam_role.writeonly_logs_role.name
}
