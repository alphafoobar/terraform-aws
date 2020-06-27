variable "aws_cidr_block" {
  type = string
  default = "10.1.0.0/16"
}

variable "aws_identity_account" {
  type = string
  description = "The account used to manage identities"
}

variable "aws_profile" {
  type = string
  default = "default"
}

variable "aws_region" {
  type = string
  default = "ap-southeast-2"
}

variable "tags" {
  type = map(string)
  description = "A map of tags that will be added to all resources"
  default = {}
}