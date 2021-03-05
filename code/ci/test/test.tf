terraform {
  backend "s3" {
    bucket         = "example-terraform-state-bucket" # set to your own S3 bucket name
    key            = "fastly/services/test-servicename/terraform.tfstate" #ID0001 - #Do NOT change this line
    region         = "us-west-2" # put your desired region here
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2" # put your desired region here
}
