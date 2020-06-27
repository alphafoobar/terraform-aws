module "vpc" {
  source     = "git::https://github.com/bnc-projects/terraform-vpc.git?ref=1.0.0"
  cidr_block = var.aws_cidr_block
  name       = "kaizen-${terraform.workspace}"
  tags       = local.tags
}