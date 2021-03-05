# This example uses a known-working pinned Fastly version
# If you use a different version you will be in uncharted waters

terraform {
  required_providers {
    fastly = {
      source = "fastly/fastly"
      version = "0.21.2" # Pinned version of Fastly TF Provider
    }
  }
  required_version = ">= 0.13" # required version of Terraform
}
