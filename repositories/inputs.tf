variable "aws_region" {
  default = "eu-west-1"
  type    = string
}

provider "aws" {
  region = var.aws_region
}
