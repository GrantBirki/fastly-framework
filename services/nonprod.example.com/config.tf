terraform {
  backend "s3" {
    bucket         = "example-terraform-state-bucket" # set to your own S3 bucket name
    key            = "fastly/services/nonprod.example.com/terraform.tfstate" # change nonprod.example.com
    region         = "us-west-2" # put your desired region here
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
provider "aws" {
  region = "us-west-2" # put your desired region here
}

