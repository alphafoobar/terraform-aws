locals {
  tags = merge({
    owner       = "kaizen7"
    environment = terraform.workspace
  }, var.tags)
}