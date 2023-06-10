####################################### Velociraptor S3 bucket #######################################
data "aws_iam_policy_document" "raptor_uploader" {
  statement {
    sid       = "AllowRaptorToUpload"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.raptor_uploader.arn}/*"]
  }

  statement {
    sid = "AllowRaptorToListBucket"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.raptor_uploader.arn]
  }
}

resource "aws_iam_policy" "raptor_uploader" {
  name   = "${var.PROJECT_PREFIX}-raptor-uploader"
  policy = data.aws_iam_policy_document.raptor_uploader.json
}


resource "aws_iam_user" "raptor_uploader" {
  name = "${var.PROJECT_PREFIX}-raptor-uploader"

  tags = {
    Project = var.PROJECT_PREFIX
  }
}


resource "aws_iam_user_policy_attachment" "raptor_uploader" {
  user       = aws_iam_user.raptor_uploader.name
  policy_arn = aws_iam_policy.raptor_uploader.arn
}
