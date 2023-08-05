######################################## teleport_workshop_contribs policies ########################################
data "aws_iam_policy_document" "teleport_workshop_contribs_ec2" {
  statement {
    sid = "AllowWorkshopContribsToTurnEC2MachinesOnOff"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.PROJECT_PREFIX]
    }

  }
  statement {
    sid = "AllowWorkshopContribsToListEC2MachinesAttributes"
    actions = [
      "ec2:Describe*",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "teleport_workshop_contribs_s3" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketAcl",
      "s3:ListAccessPoints",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.project_bucket.arn,
      aws_s3_bucket.raptor_uploader.arn,
      aws_s3_bucket.insider_threat.arn,
      aws_s3_bucket.logs_infra.arn,
      aws_s3_bucket.logs_archive_raw.arn,
      aws_s3_bucket.logs_archive_enriched.arn,
    ]
  }
  statement {
    actions = [
      "s3:List*",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.project_bucket.arn}/*",
      "${aws_s3_bucket.raptor_uploader.arn}/*",
      "${aws_s3_bucket.insider_threat.arn}/*",
      "${aws_s3_bucket.logs_infra.arn}/*",
      "${aws_s3_bucket.logs_archive_raw.arn}/*",
      "${aws_s3_bucket.logs_archive_enriched.arn}/*",
    ]
  }
}


resource "aws_iam_policy" "teleport_workshop_contribs_ec2" {
  name   = "${var.PROJECT_PREFIX}_teleport_workshop_contribs_ec2"
  policy = data.aws_iam_policy_document.teleport_workshop_contribs_ec2.json
}

resource "aws_iam_policy" "teleport_workshop_contribs_s3" {
  name   = "${var.PROJECT_PREFIX}_teleport_workshop_contribs_s3"
  policy = data.aws_iam_policy_document.teleport_workshop_contribs_s3.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "teleport_workshop_contribs_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "teleport_workshop_contribs" {
  name               = "${var.PROJECT_PREFIX}_teleport_workshop_contribs"
  assume_role_policy = data.aws_iam_policy_document.teleport_workshop_contribs_trust.json
}

resource "aws_iam_role_policy_attachment" "teleport_workshop_contribs_s3" {
  role       = aws_iam_role.teleport_workshop_contribs.name
  policy_arn = aws_iam_policy.teleport_workshop_contribs_s3.arn
}

resource "aws_iam_role_policy_attachment" "teleport_workshop_contribs_ec2" {
  role       = aws_iam_role.teleport_workshop_contribs.name
  policy_arn = aws_iam_policy.teleport_workshop_contribs_ec2.arn
}

######################################## Teleport role attachment ########################################
# https://goteleport.com/docs/application-access/cloud-apis/aws-console/#step-39-give-teleport-permissions-to-assume-roles
data "aws_iam_policy_document" "teleport_allow_assume_roles" {
  statement {
    sid       = "AllowTelpeortToAssumeIAMRoles"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "teleport_allow_assume_roles" {
  name   = "${var.PROJECT_PREFIX}_teleport_allow_assume_roles"
  policy = data.aws_iam_policy_document.teleport_allow_assume_roles.json
}

resource "aws_iam_role_policy_attachment" "teleport_allow_assume_roles_attach" {
  role       = "${var.PROJECT_PREFIX}-teleport-cluster"
  policy_arn = aws_iam_policy.teleport_allow_assume_roles.arn
}

######################################## Teleport trust relationship attachment ########################################
