provider "aws" {
  region                  = "us-west-2"
  profile                 = "sh-sandbox"
}
terraform {
  backend "s3" {
    bucket = "sh-terraform"
    key    = "state/terraform.tfstate"
    region = "us-west-2"
    profile = "sh-sandbox"
  }
}
