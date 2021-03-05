terraform {
  backend "s3" {
    bucket         = "example-terraform-state-bucket" # set to your own S3 bucket name
    key            = "fastly/infrastructure/fastly-to-insights/terraform.tfstate" # You may change if you want but you don't have to
    region         = "us-west-2" # put your desired region here
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2" # put your desired region here
}