data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    sid    = "AllowECSToAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs-role" {
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  name               = "ecs-container-instance-role"
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs-service-policy" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-agent-policy" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ecs-profile" {
  name = "ecs-profile"
  role = aws_iam_role.ecs-role.name
}

// See https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
resource "aws_ecs_cluster" "kaizen-ecs" {
  name = "kaizen-ecs"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags               = local.tags
}

