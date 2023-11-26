terraform {
  backend "s3" {
    bucket = "kandidat2010"
    key = "state/production/terraform.tfstate"
    region = "eu-west-1"
  }
}
