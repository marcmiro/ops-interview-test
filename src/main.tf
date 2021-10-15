provider "aws" {}

data "aws_region" "current" {}

terraform {
  required_version = ">= 0.12"

  # backend "s3" {
  #   bucket         = "test"
  #   key            = "${region}/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform_locks"
  # }
}
