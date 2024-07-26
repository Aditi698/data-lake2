provider "aws" {
  region  = "eu-west-1"
}


module "data_lake" {
  source = "../modules"
  src-email = var.SRC-email
  rec-email = var.REC-email
}

