terraform {
  required_version = ">= 0.12"
  backend "s3" {
    # Region cannot be referenced as a variable.
    region = "ap-southeast-2"
    # Profile cannot be referenced as a variable.
    profile  = "kaizen-terraform"

    bucket = "ops.kaizen7.nz"
    key = "example"
    workspace_key_prefix = "ops"
    encrypt = true
  }
}