provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.profile
  region                   = var.primary_region
}