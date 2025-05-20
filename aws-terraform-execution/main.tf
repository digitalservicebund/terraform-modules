resource "aws_iam_role" "terraform_execution" {
  name               = "terraform-execution"
  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json
}

data "aws_iam_policy_document" "self_control" {
  # Deny updating itself
  statement {
    sid    = "SelfControl"
    effect = "Deny"
    actions = [
      "iam:Create*",
      "iam:Delete*",
      "iam:Update*",
      "iam:Put*",
      "iam:Add*",
      "iam:Remove*",
      "iam:Attach*",
      "iam:Detach*"
    ]
    resources = [
      aws_iam_role.terraform_execution.arn,
      "${aws_iam_role.terraform_execution.arn}:*",
    ]
  }
}

data "aws_iam_policy_document" "combined_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.self_control.json,
    var.terraform_execution_policy
  ]
}

resource "aws_iam_policy" "terraform_policy" {
  name        = "terraform-policy"
  description = "IAM policy to execute terraform"
  policy      = data.aws_iam_policy_document.combined_policy.json
}

resource "aws_iam_role_policy_attachment" "terraform_policy_attachment" {
  role       = aws_iam_role.terraform_execution.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}
