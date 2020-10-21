provider "aws" {
  region                  = var.region
  shared_credentials_file = var.credential_path
  profile                 = var.profile
  version                 = ">= 2.33.0"
}
