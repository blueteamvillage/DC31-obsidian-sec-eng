resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # "repo:<org>/<repo>:*",
      values = ["repo:blueteamvillage/DC31-obsidian-sec-eng:*"]
    }
  }
}

data "aws_iam_policy_document" "github_actions" {
  version = "2012-10-17"
  # Allow Github action to read secret to verify value
  statement {
    sid       = "AllowGHAtoReadWinDCPassword"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.win_domain_admin_passwd.id]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "${var.PROJECT_PREFIX}-policy"
  description = "${var.PROJECT_PREFIX} policy"
  policy      = data.aws_iam_policy_document.github_actions.json
}


resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role = aws_iam_role.github_actions.name
  # AWS managed READ-ONLY policy
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "github_actions_perms" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
