provider "aws" {
  default_tags {
    tags = {
      iac_tool  = "terraform"
      iac_repo  = "terraform-aws-ec2-ssm-roles"
      iac_owner = "Simon Hanmer"
    }
  }
}


terraform {
  backend "s3" {
    encrypt = true
  }
}
