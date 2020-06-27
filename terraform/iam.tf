data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowUsersInIdentityAccountToAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.aws_identity_account}:root"
      ]
    }
  }
}

resource "aws_iam_role" "deployment_role" {
  name               = "TerraformRole"
  description        = "Allows Terraform full access to perform functions"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = local.tags
}